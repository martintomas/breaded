# frozen_string_literal: true

require 'test_helper'

class  Subscriptions::NewSubscriptionFormerTest < ActiveSupport::TestCase
  setup do
    @user = users(:customer)
    @full_content = { subscription_plan_id: subscription_plans(:once_every_month).id,
                      delivery_date_from: Time.zone.parse('19th Oct 2020 10:00:00'),
                      delivery_date_to: Time.zone.parse('19th Oct 2020 14:00:00'),
                      address_line: 'Address Line',
                      street: 'Street',
                      city: 'City',
                      postal_code: 'test',
                      shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE,
                      user: @user,
                      basket_items: [{ id: foods(:rye_bread).id, amount: 5 },
                                     { id: foods(:seeded_bread).id, amount: Rails.application.config.options[:default_number_of_breads] - 5 }].to_json }
    @user.addresses.delete_all
    @user.subscriptions.update_all active: false
  end

  test 'the validity - empty is not valid' do
    model = Subscriptions::NewSubscriptionFormer.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Subscriptions::NewSubscriptionFormer.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription_plan_id is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :subscription_plan_id
  end

  test 'the validity - without delivery_date_from is valid' do
    model = Subscriptions::NewSubscriptionFormer.new @full_content.except(:delivery_date_from)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without delivery_date_to is valid' do
    model = Subscriptions::NewSubscriptionFormer.new @full_content.except(:delivery_date_to)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without address_line is valid' do
    model = Subscriptions::NewSubscriptionFormer.new @full_content.except(:address_line)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without street is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :street
  end

  test 'the validity - without city is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :city
  end

  test 'the validity - without postal_code is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :postal_code
  end

  test 'the validity - without shopping_basket_variant is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :shopping_basket_variant
  end

  test 'the validity - without user is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :user
  end

  test 'the validity - without basket_items is not valid' do
    invalid_with_missing Subscriptions::NewSubscriptionFormer, :basket_items
  end

  test 'the validity - user cannot have any active subscription' do
    @user.subscriptions.first.update! active: true

    former = Subscriptions::NewSubscriptionFormer.new @full_content
    refute former.valid?
    assert_equal :already_active_subscription, former.errors.details[:base].first[:error]
  end

  test 'the validity - validator is run above basket items' do
    @full_content[:basket_items] = [{ id: '', amount: Rails.application.config.options[:default_number_of_breads] + 1 }].to_json

    former = Subscriptions::NewSubscriptionFormer.new @full_content
    refute former.valid?
    assert_equal :too_many_items, former.errors.details[:base].first[:error]
  end

  test '#initialize - it preload address for user with address' do
    @user.addresses.create! address_type: AddressType.the_personal, address_line: 'Address Line', street: 'Street 1',
                            postal_code: '54546', city: 'London', state: 'UK'

    former = Subscriptions::NewSubscriptionFormer.new @full_content.except(:address_line, :street, :postal_code, :city)
    assert_equal 'Address Line', former.address_line
    assert_equal 'Street 1', former.street
    assert_equal '54546', former.postal_code
    assert_equal 'London', former.city
  end

  test '#save - new subscription gets saved' do
    assert_difference -> { Subscription.count }, 1 do
      former = Subscriptions::NewSubscriptionFormer.new @full_content
      former.save

      subscription = Subscription.last
      assert_equal subscription_plans(:once_every_month), subscription.subscription_plan
      assert_equal @user, subscription.user
      refute subscription.active
      assert_equal Rails.application.config.options[:default_number_of_breads], subscription.number_of_items
    end
  end

  test '#save - new address gets saved' do
    assert_difference -> { Address.count }, 2 do # user and order
      former = Subscriptions::NewSubscriptionFormer.new @full_content
      former.save

      address = @user.address
      assert_equal AddressType.the_personal, address.address_type
      assert_equal 'Address Line', address.address_line
      assert_equal 'Street', address.street
      assert_equal 'City', address.city
      assert_equal 'test', address.postal_code
      assert_equal 'UK', address.state
      assert_equal 'Address Line', address.address_line
    end
  end

  test '#save - old address gets updated' do
    @user.addresses.create! address_type: AddressType.the_personal, address_line: 'Old Address Line', street: 'Street 1',
                            postal_code: '54546', city: 'London', state: 'UK'

    assert_difference -> { Address.count }, 1 do # order
      former = Subscriptions::NewSubscriptionFormer.new @full_content
      former.save

      address = @user.address
      assert_equal AddressType.the_personal, address.address_type
      assert_equal 'Address Line', address.address_line
      assert_equal 'Street', address.street
      assert_equal 'City', address.city
      assert_equal 'test', address.postal_code
      assert_equal 'UK', address.state
      assert_equal 'Address Line', address.address_line
    end
  end

  test '#save - it creates subscription period with appropriate delivery dates' do
    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      assert_difference -> { SubscriptionPeriod.count }, 1 do
        former = Subscriptions::NewSubscriptionFormer.new @full_content
        former.save

        subscription_period = SubscriptionPeriod.last
        assert_equal former.subscription, subscription_period.subscription
        assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, subscription_period.started_at.to_i
        assert_equal Time.zone.parse('19th Nov 2020 10:00:00').to_i, subscription_period.ended_at.to_i
        refute subscription_period.paid
      end
    end
  end

  test '#save - it creates orders based on subscription plan' do
    travel_to Time.zone.parse('10th Oct 2020 10:00:00') do
      assert_difference -> { Order.count }, 1 do
        former = Subscriptions::NewSubscriptionFormer.new @full_content
        former.save

        order = Order.last
        assert_equal Time.zone.parse('19th Oct 2020 10:00:00').to_i, order.delivery_date_from.to_i
        assert_equal Time.zone.parse('19th Oct 2020 14:00:00').to_i, order.delivery_date_to.to_i
        assert_equal @user, order.user
        assert_equal 5, order.order_foods.find_by_food_id(foods(:rye_bread).id).amount
        assert_equal Rails.application.config.options[:default_number_of_breads] - 5,
                     order.order_foods.find_by_food_id(foods(:seeded_bread).id).amount
        assert_equal @user.address.slice('address_line', 'street', 'postal_code', 'city', 'state', 'address_type_id'),
                     order.address.slice('address_line', 'street', 'postal_code', 'city', 'state', 'address_type_id')
      end
    end
  end
end
