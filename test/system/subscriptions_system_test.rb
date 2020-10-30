# frozen_string_literal: true

require "application_system_test_case"
require 'mocks/twilio'

class SubscriptionsSystemTest < ApplicationSystemTestCase
  include Mocks::Twilio

  setup do
    login_as_customer
    @user = users :customer
    @user.subscriptions.update_all active: false
  end

  test '#create - user with already active subscription cannot create other one' do
    @user.subscriptions.first.update! active: true
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      visit new_subscription_path(shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

      fill_new_subscription_form
      click_button I18n.t('app.get_breaded.submit')

      assert_selector 'div#error_explanation > ul > li', text: I18n.t('activemodel.errors.models.subscriptions/new_subscription_former.attributes.base.already_active_subscription')
    end
  end
  
  test '#create - failed basket validation' do
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      visit new_subscription_path(shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

      fill_new_subscription_form
      click_button I18n.t('app.get_breaded.submit')

      assert_selector 'div#error_explanation > ul > li', text: I18n.t('activemodel.errors.models.subscriptions/new_subscription_former.attributes.base.missing_items')
    end
  end

  test '#create - failed phone verification' do
    @user.update! phone_number: nil
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      visit new_subscription_path(shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

      fill_new_subscription_form
      fill_in 'subscriptions_new_subscription_former[phone_number]', with: '+420734370408'
      click_button I18n.t('app.get_breaded.submit')

      assert_selector 'div#error_explanation > ul > li', text: I18n.t('activemodel.errors.models.subscriptions/new_subscription_former.attributes.phone_number.not_valid')
    end
  end


  test '#create - pick up breads subscription' do
    food_id = add_items_to_basket!
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      assert_difference -> { Subscription.count }, 1 do
        assert_difference -> { Order.count }, SubscriptionPlan.order(:id).first.number_of_deliveries do
          visit new_subscription_path(shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

          fill_new_subscription_form
          verify_phone_number! '+420734370407'

          click_button I18n.t('app.get_breaded.submit')

          assert_selector 'h2', text: I18n.t('app.get_breaded.payment.title')

          # updates user
          assert_equal '+420734370407', @user.reload.phone_number
          assert_equal 'Address Line', @user.address.address_line
          assert_equal 'Street', @user.address.street
          assert_equal 'City', @user.address.city
          assert_equal '123456', @user.address.postal_code

          # creates correct subscription
          subscription = Subscription.last
          assert_equal @user, subscription.user
          refute subscription.active

          # creates correct order
          order = Subscription.last.orders.order(:delivery_date_from).first
          assert_equal Time.zone.parse('"2020-11-03 10:00:00 +0000"').to_i, order.delivery_date_from.to_i
          assert_equal Rails.application.config.options[:default_number_of_breads], order.order_foods.first.amount
          assert_equal food_id, order.order_foods.first.food_id
        end
      end
    end
  end

  test '#create - surprise me subscription' do
    ingredients_preference_id, bread_preference_id = add_preferences_to_basket!
    travel_to Time.zone.parse('25th Oct 2020 04:00:00') do
      assert_difference -> { Subscription.count }, 1 do
        assert_difference -> { Order.count }, SubscriptionPlan.order(:id).first.number_of_deliveries do
          visit new_subscription_path(shopping_basket_variant: Orders::UpdateFromBasket::SURPRISE_ME_TYPE)

          fill_new_subscription_form
          verify_phone_number! '+420734370407'

          click_button I18n.t('app.get_breaded.submit')

          assert_selector 'h2', text: I18n.t('app.get_breaded.payment.title')

          # updates user
          assert_equal '+420734370407', @user.reload.phone_number
          assert_equal 'Address Line', @user.address.address_line
          assert_equal 'Street', @user.address.street
          assert_equal 'City', @user.address.city
          assert_equal '123456', @user.address.postal_code

          # creates correct subscription
          subscription = Subscription.last
          assert_equal @user, subscription.user
          refute subscription.active

          # creates correct order
          order = Subscription.last.orders.order(:delivery_date_from).first
          assert_equal Time.zone.parse('"2020-11-03 10:00:00 +0000"').to_i, order.delivery_date_from.to_i
          assert_equal 1, order.order_surprises.joins(:tag).where(tags: { id: ingredients_preference_id }).first.amount
          assert_nil order.order_surprises.joins(:tag).where(tags: { id: bread_preference_id }).first.amount
        end
      end
    end
  end

  private

  def fill_new_subscription_form
    find('a.calenderSec').click
    find('span[data-timestamp="2020-11-03 10:00:00 +0000"]').click
    fill_in 'subscriptions_new_subscription_former[address_line]', with: 'Address Line'
    fill_in 'subscriptions_new_subscription_former[street]', with: 'Street'
    fill_in 'subscriptions_new_subscription_former[city]', with: 'City'
    fill_in 'subscriptions_new_subscription_former[postal_code]', with: '123456'
  end

  def verify_phone_number!(phone_number)
    fill_in 'subscriptions_new_subscription_former[phone_number]', with: phone_number

    Twilio::VerifyPhoneNumber.stub_any_instance :random_number, '123456' do
      Twilio::REST::Client.stub :new, mock_twilio_for do
        click_link I18n.t('app.get_breaded.phone_number.link')
        fill_in I18n.t('app.get_breaded.phone_number.popup.otp_code'), with: '123456'
        click_button I18n.t('app.get_breaded.phone_number.popup.confirm')
      end
    end
  end

  def add_preferences_to_basket!
    visit surprise_me_foods_path

    ingredients_preference_id = tags(:vegetarian_tag).id
    bread_preference_id = tags(:sourdough_tag).id

    find("div.inc.button[data-tag-id='#{ingredients_preference_id}']").click
    find("input[type='checkbox'][data-tag-id='#{bread_preference_id}']").execute_script('this.click();')
    [ingredients_preference_id, bread_preference_id]
  end

  def add_items_to_basket!
    visit foods_path

    food_id = Food.enabled.first.id
    Rails.application.config.options[:default_number_of_breads].times do
      find("div.inc.button[data-food-id='#{food_id}']", match: :first).click
    end
    food_id
  end
end
