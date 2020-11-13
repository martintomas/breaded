# frozen_string_literal: true

require 'test_helper'

class  Orders::UpdateFormerTest < ActiveSupport::TestCase
  setup do
    @user = users :customer
    @order = orders :customer_order_1
    @full_content = { order: @order,
                      secondary_phone_number: '420999999999',
                      delivery_date_from: '19th Oct 2020 10:00:00',
                      address_line: 'Address Line',
                      street: 'Street',
                      city: 'City',
                      postal_code: 'test',
                      shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE,
                      basket_items: [{ id: foods(:rye_bread).id, amount: 5 },
                                     { id: foods(:seeded_bread).id, amount: Rails.application.config.options[:default_number_of_breads] - 5 }].to_json }
  end

  test 'the validity - empty is not valid' do
    model = Orders::UpdateFormer.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Orders::UpdateFormer.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without order is not valid' do
    invalid_with_missing Orders::UpdateFormer, :order
  end

  test 'the validity - without secondary_phone_number is valid' do
    model = Orders::UpdateFormer.new @full_content.except(:secondary_phone_number)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without delivery_date_from is valid' do
    Availability.stub :available_at?, true, [@order.delivery_date_from] do
      model = Orders::UpdateFormer.new @full_content.except(:delivery_date_from)
      assert model.valid?, model.errors.full_messages
    end
  end

  test 'the validity - without address_line is not valid' do
    model = Orders::UpdateFormer.new @full_content.except(:address_line)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without street is not valid' do
    model = Orders::UpdateFormer.new @full_content.except(:street)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without city is not valid' do
    model = Orders::UpdateFormer.new @full_content.except(:city)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without postal code is not valid' do
    model = Orders::UpdateFormer.new @full_content.except(:postal_code)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without shopping_basket_variant is not valid' do
    invalid_with_missing Orders::UpdateFormer, :shopping_basket_variant
  end

  test 'the validity - without basket_items is not valid' do
    invalid_with_missing Orders::UpdateFormer, :basket_items
  end

  test 'the validity - delivery date from has to be at predefined times' do
    @full_content[:delivery_date_from] = '14th Nov 2020 10:00:00'

    former = Orders::UpdateFormer.new @full_content
    refute former.valid?
    assert_equal :invalid_date, former.errors.details[:delivery_date_from].first[:error]
  end

  test 'the validity - validator is run above basket items' do
    @full_content[:basket_items] = [{ id: '', amount: Rails.application.config.options[:default_number_of_breads] + 1 }].to_json

    former = Orders::UpdateFormer.new @full_content
    refute former.valid?
    assert_equal :too_many_items, former.errors.details[:base].first[:error]
  end

  test '#initialize - it preload address for user with address' do
    @order.address.destroy
    former = Orders::UpdateFormer.new @full_content.except(:address_line, :street, :postal_code, :city)

    assert_equal @user.address.address_line, former.address_line
    assert_equal @user.address.street, former.street
    assert_equal @user.address.postal_code, former.postal_code
    assert_equal @user.address.city, former.city
  end

  test '#initialize - it preload order with default values' do
    former = Orders::UpdateFormer.new @full_content.except(:delivery_date_from)

    assert_equal @order.delivery_date_from, former.delivery_date_from
  end

  test '#initialize - it preload user with default values' do
    former = Orders::UpdateFormer.new @full_content.except(:phone_number, :secondary_phone_number)

    assert_equal @order.user, former.user
    assert_equal @user.phone_number, former.phone_number
    assert_equal @user.secondary_phone_number, former.secondary_phone_number
  end

  test '#save - address of order gets updated' do
    assert_no_difference -> { Address.count } do
      Orders::UpdateFormer.new(@full_content).save

      @order.reload
      assert_equal 'Address Line', @order.address.address_line
      assert_equal 'Street', @order.address.street
      assert_equal 'City', @order.address.city
      assert_equal 'test', @order.address.postal_code
      assert_equal 'UK', @order.address.state
    end
  end

  test '#save - address of order gets created' do
    @order.address.destroy
    @order.reload

    assert_difference -> { Address.count }, 1 do
      Orders::UpdateFormer.new(@full_content).save

      @order.reload
      assert_equal 'Address Line', @order.address.address_line
      assert_equal 'Street', @order.address.street
      assert_equal 'City', @order.address.city
      assert_equal 'test', @order.address.postal_code
      assert_equal 'UK', @order.address.state
    end
  end

  test '#save - secondary phone number of user gets saved' do
    Orders::UpdateFormer.new(@full_content).save

    assert_equal @user.reload.secondary_phone_number, '+420999999999'
  end

  test '#save - updates order' do
    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      Orders::UpdateFormer.new(@full_content).save

      @order.reload
      assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, @order.delivery_date_from.to_i
      assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, @order.delivery_date_to.to_i
      assert_equal 5, @order.order_foods.find_by_food_id(foods(:rye_bread).id).amount
      assert_equal Rails.application.config.options[:default_number_of_breads] - 5,
                   @order.order_foods.find_by_food_id(foods(:seeded_bread).id).amount
      assert @order.placed?
    end
  end
end
