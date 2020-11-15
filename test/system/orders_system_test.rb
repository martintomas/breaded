# frozen_string_literal: true

require "application_system_test_case"
require 'mocks/twilio'

class OrdersSystemTest < ApplicationSystemTestCase
  include Mocks::Twilio

  setup do
    login_as_customer
    @user = users :customer
    @order = orders :customer_order_2
  end

  test '#pick_breads_option' do
    visit subscription_period_path(@order.subscription_period)

    within ".order-detail-section[data-order-id='#{@order.id}']" do
      find('.drop-down .selected').click
      find('.drop-down .options ul li', text: I18n.t("app.users.show.pick_bread_#{@order.position}")).click

      find('button', text: I18n.t('app.users.show.pick_breads_button')).click
      assert_current_path edit_order_path(@order)
    end
  end

  test '#copy_order_option' do
    visit subscription_period_path(@order.subscription_period)

    within ".order-detail-section[data-order-id='#{@order.id}']" do
      find('.drop-down .selected').click
      find('.drop-down .options ul li', text: I18n.t("app.users.show.repeat_box_#{@order.position - 1}")).click

      find('button', text: I18n.t('app.users.show.confirm_button')).click
      find('button', text: I18n.t('app.users.show.bread_list_button')).click
      assert_current_path order_path(@order)
    end
  end

  test '#update_date' do
    travel_to Time.zone.parse('13th Oct 2020 04:00:00') do
      fix_order_time_with! Time.zone.parse('19th Oct 2020 04:00:00')
      visit subscription_period_path(@order.subscription_period)

      within ".order-detail-section[data-order-id='#{@order.id}']" do
        within '.devliveyTime' do
          click_link I18n.t('app.users.show.delivery_time.change')
          find("span[data-timestamp='2020-10-20 10:00:00 +0100']").click
          click_button I18n.t('app.get_breaded.calendar.submit')

          assert_selector 'span.date-time.day-in-month', text: 'Tuesday 20 Oct'
          assert_selector 'span.date-time.time-range', text: '10:00 am - 2:00 pm'
        end
      end
    end
  end

  test '#update_address' do
    visit subscription_period_path(@order.subscription_period)

    within ".order-detail-section[data-order-id='#{@order.id}']" do
      within 'address' do
        click_link I18n.t('app.users.show.address.change')

        assert_selector 'h3.title', text: I18n.t('app.users.show.address.popup.title')
        fill_in 'address[address_line]', with: 'Updated Address Line'
        fill_in 'address[street]', with: 'Updated Street'
        fill_in 'address[city]', with: 'Updated City'
        fill_in 'address[postal_code]', with: 'Updated Postal Code'
        click_button I18n.t('app.addresses.new.submit')

        assert_text 'Updated Address Line, Updated Street Updated City - Updated Postal Code'
      end
    end
  end

  test '#update - pick food' do
    travel_to Time.zone.parse('13th Oct 2020 04:00:00') do
      fix_order_time_with! Time.zone.parse('19th Oct 2020 04:00:00')

      food_id = add_items_to_basket!
      select_date_for! '2020-10-20 10:00:00 +0100'
      update_delivery_address!
      verify_phone_number! '+420734370407'
      fill_in 'orders_update_former[secondary_phone_number]', with: '+420333333333'
      click_button I18n.t('app.orders.confirm_update.confirm_button')

      assert_current_path subscription_period_path(@order.subscription_period)

      # updates user
      assert_equal '+420734370407', @user.reload.phone_number
      assert_equal '+420333333333', @user.secondary_phone_number
      # updates order address
      @order.reload
      assert_equal 'Updated Address Line', @order.address.address_line
      assert_equal 'Updated Street', @order.address.street
      assert_equal 'Updated City', @order.address.city
      assert_equal 'Updated Postal Code', @order.address.postal_code
      # updates order
      assert_equal Time.zone.parse('"2020-10-20 10:00:00 +0100"').to_i, @order.delivery_date_from.to_i
      assert_equal Rails.application.config.options[:default_number_of_breads], @order.order_foods.first.amount
      assert_equal food_id, @order.order_foods.first.food_id
    end
  end

  test '#update - surprise me' do
    travel_to Time.zone.parse('13th Oct 2020 04:00:00') do
      fix_order_time_with! Time.zone.parse('19th Oct 2020 04:00:00')

      ingredients_preference_id, bread_preference_id = add_preferences_to_basket!
      select_date_for! '2020-10-20 10:00:00 +0100'
      update_delivery_address!
      verify_phone_number! '+420734370407'
      fill_in 'orders_update_former[secondary_phone_number]', with: '+420333333333'
      click_button I18n.t('app.orders.confirm_update.confirm_button')

      assert_current_path subscription_period_path(@order.subscription_period)

      # updates user
      assert_equal '+420734370407', @user.reload.phone_number
      assert_equal '+420333333333', @user.secondary_phone_number
      # updates order address
      @order.reload
      assert_equal 'Updated Address Line', @order.address.address_line
      assert_equal 'Updated Street', @order.address.street
      assert_equal 'Updated City', @order.address.city
      assert_equal 'Updated Postal Code', @order.address.postal_code
      # updates order
      assert_equal Time.zone.parse('"2020-10-20 10:00:00 +0100"').to_i, @order.delivery_date_from.to_i
      assert_equal 1, @order.order_surprises.joins(:tag).where(tags: { id: ingredients_preference_id }).first.amount
      assert_nil @order.order_surprises.joins(:tag).where(tags: { id: bread_preference_id }).first.amount
    end
  end

  test '#update - bread details shows correct basket' do
    food = Food.enabled.first
    within ".order-detail-section[data-order-id='#{@order.id}']" do
      find('button', text: I18n.t('app.users.show.pick_breads_button')).click
    end
    find("div.inc.button[data-food-id='#{food.id}']", match: :first).click

    find("a[href='#{food_path(food, basket_prefix: "order-id-#{@order.id}", root_url: edit_order_path(@order))}']").click
    assert_equal 1, find("input[type='text']").value.to_i
    find('ul.breadcrumbs li', text: I18n.t('app.menu.browse_breads')).click

    assert_current_path edit_order_path(@order)
  end

  private

  def fix_order_time_with!(value)
    @order.update! delivery_date_from: value, delivery_date_to: value
  end

  def add_items_to_basket!
    within ".order-detail-section[data-order-id='#{@order.id}']" do
      find('button', text: I18n.t('app.users.show.pick_breads_button')).click
    end

    Food.enabled.first.id.tap do |food_id|
      Rails.application.config.options[:default_number_of_breads].times do
        find("div.inc.button[data-food-id='#{food_id}']", match: :first).click
      end
      click_button I18n.t('app.surprise_me.confirm')
    end
  end

  def add_preferences_to_basket!
    within ".order-detail-section[data-order-id='#{@order.id}']" do
      find('button', text: I18n.t('app.users.show.pick_breads_button')).click
    end
    find('button', text: I18n.t('app.browse_bread.menu_surprise_me')).click

    ingredients_preference_id = tags(:vegetarian_tag).id
    bread_preference_id = tags(:sourdough_tag).id

    find("div.inc.button[data-tag-id='#{ingredients_preference_id}']").click
    find("input[type='checkbox'][data-tag-id='#{bread_preference_id}']").execute_script('this.click();')
    click_button I18n.t('app.surprise_me.confirm')
    [ingredients_preference_id, bread_preference_id]
  end

  def select_date_for!(value)
    find('a.calenderSec').click
    find("span[data-timestamp='#{value}']").click
    click_button I18n.t('app.get_breaded.calendar.submit')
  end

  def update_delivery_address!
    within '.address-section' do
      click_link I18n.t('app.orders.confirm_update.address.change')
    end
    fill_in 'orders_update_former[address_line]', with: 'Updated Address Line'
    fill_in 'orders_update_former[street]', with: 'Updated Street'
    fill_in 'orders_update_former[city]', with: 'Updated City'
    fill_in 'orders_update_former[postal_code]', with: 'Updated Postal Code'
    click_button I18n.t('app.orders.confirm_update.address.save')
    within '.address-section' do
      assert_selector '.address-line', text: 'Updated Address Line, Updated Street, Updated City'
      assert_selector '.postal-code', text: 'Updated Postal Code'
    end
  end

  def verify_phone_number!(phone_number)
    fill_in 'orders_update_former[phone_number]', with: phone_number

    Twilio::VerifyPhoneNumber.stub_any_instance :random_number, '123456' do
      Twilio::REST::Client.stub :new, mock_twilio_for do
        click_link I18n.t('app.get_breaded.phone_number.link')
        fill_in I18n.t('app.get_breaded.phone_number.popup.otp_code'), with: '123456'
        click_button I18n.t('app.get_breaded.phone_number.popup.confirm')
      end
    end
  end
end
