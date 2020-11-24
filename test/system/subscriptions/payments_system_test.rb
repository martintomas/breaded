# frozen_string_literal: true

require "application_system_test_case"

class Subscriptions::PaymentsSystemTest < ApplicationSystemTestCase
  setup do
    WebMock.allow_net_connect!

    login_as_customer
    @subscription = subscriptions :customer_subscription_1
    @subscription.update! active: false
    add_new_stripe_product!
  end

  teardown do
    WebMock.disable_net_connect!(allow_localhost: true, allow: AllowedSites.all)
  end

  test '#new - subscription crashed' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000009987'
    click_button I18n.t('app.get_breaded.payment.submit')

    using_wait_time(10) do
      assert_selector 'div#error_explanation > ul > li', text: 'Your card was declined'
    end
  end

  test '#new - subscription crashed with requires payment error' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000000341'
    click_button I18n.t('app.get_breaded.payment.submit')

    using_wait_time(10) do
      assert_selector 'div#error_explanation > ul > li', text: I18n.t('app.stripe.default_error')
    end
  end

  test '#new - requires 3D secure check that fails' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000003220'
    click_button I18n.t('app.get_breaded.payment.submit')

    complete_stripe_sca_with 'Fail'

    using_wait_time(10) do
      assert_selector 'div#error_explanation > ul > li', text: 'We are unable to authenticate your payment method. Please choose a different payment method and try again.'
    end
  end

  test '#new - requires 3D secure check that passes' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000003220'
    click_button I18n.t('app.get_breaded.payment.submit')

    complete_stripe_sca_with 'Complete'

    using_wait_time(10) do
      assert_text I18n.t('app.get_breaded.payment.success.go_to_my_boxes')
    end
  end

  test '#new' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4242424242424242'
    click_button I18n.t('app.get_breaded.payment.submit')

    using_wait_time(10) do
      click_link I18n.t('app.get_breaded.payment.success.go_to_my_boxes')
      assert_current_path subscription_period_path(subscription_periods(:customer_1_subscription_2_period))
    end
  end

  test '#new - continue with picking up second order' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4242424242424242'
    click_button I18n.t('app.get_breaded.payment.submit')

    using_wait_time(10) do
      click_link I18n.t('app.get_breaded.payment.success.go_to_second_box')
      assert_current_path edit_order_path(orders(:customer_order_2))
    end
  end

  test '#show' do
    User.stub_any_instance :payment_method, OpenStruct.new(card: OpenStruct.new(last4: '4321')) do
      visit subscription_payment_path(@subscription, id: 0)

      assert_selector 'h3.title', text: I18n.t('app.get_breaded.payment.title')
      assert_equal find('#card_number').value, '**** **** **** 4321'
    end
  end

  test '#edit' do
    activate_subscription!
    add_new_stripe_customer!
    visit edit_subscription_payment_path(@subscription, id: 0)

    fill_stripe_elements card: '4242424242424242'
    click_button I18n.t('app.get_breaded.payment.edit.submit')

    using_wait_time(10) do
      assert_equal find('#card_number').value, '**** **** **** 4242'
    end
  end

  test '#edit - with delivery address' do
    activate_subscription!
    add_new_stripe_customer!
    visit edit_subscription_payment_path(@subscription, id: 0)

    fill_stripe_elements card: '4242424242424242'
    find("label[for='same_as_delivery_address']").click
    fill_in 'address_line', with: 'New Address Line'
    fill_in 'street', with: 'New Street'
    fill_in 'city', with: 'New City'
    fill_in 'postal_code', with: 'New Postal Code'
    click_button I18n.t('app.get_breaded.payment.edit.submit')

    using_wait_time(10) do
      assert_equal find('#card_number').value, '**** **** **** 4242'
    end
  end

  test '#edit - requires 3D secure check' do
    activate_subscription!
    add_new_stripe_customer!
    visit edit_subscription_payment_path(@subscription, id: 0)

    fill_stripe_elements card: '4000000000003220'
    click_button I18n.t('app.get_breaded.payment.edit.submit')
    complete_stripe_sca_with 'Complete'

    using_wait_time(10) do
      assert_equal find('#card_number').value, '**** **** **** 3220'
    end
  end

  test '#edit - requires 3D secure check that fails' do
    activate_subscription!
    add_new_stripe_customer!
    visit edit_subscription_payment_path(@subscription, id: 0)

    fill_stripe_elements card: '4000000000003220'
    click_button I18n.t('app.get_breaded.payment.edit.submit')
    complete_stripe_sca_with 'Fail'

    using_wait_time(10) do
      assert_selector 'div#error_explanation > ul > li', text: 'We are unable to authenticate your payment method. Please choose a different payment method and try again.'
    end
  end

  private

  def fill_stripe_elements(card: , expiry: '1234', cvc: '123')
    using_wait_time(10) do
      frame = find('div.payment-card > div > iframe')
      within_frame(frame) do
        card.to_s.chars.each do |piece|
          find_field('cardnumber').send_keys(piece)
        end

        find_field('exp-date').send_keys expiry
        find_field('cvc').send_keys cvc
      end
    end
  end

  def complete_stripe_sca_with(action)
    using_wait_time(10) do
      within_frame(find('body > div > iframe')) do
        within_frame(find('#challengeFrame')) do
          click_button action
        end
      end
    end
  end

  def activate_subscription!
    @subscription.update! active: true
  end

  def add_new_stripe_customer!
    Stripe::UpdateCustomerJob.perform_now @subscription.user
  end

  def add_new_stripe_product!
    Stripe::UpdateSubscriptionPlanJob.perform_now @subscription.subscription_plan
  end
end
