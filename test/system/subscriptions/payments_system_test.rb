# frozen_string_literal: true

require "application_system_test_case"

class Subscriptions::PaymentsSystemTest < ApplicationSystemTestCase
  setup do
    WebMock.allow_net_connect!

    login_as_customer
    @subscription = subscriptions :customer_subscription_1
    add_new_stripe_product!
  end

  teardown do
    WebMock.disable_net_connect!(allow_localhost: true, allow: AllowedSites.all)
  end

  test '#new - subscription crashed' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000009987'
    click_button I18n.t('app.get_breaded.payment.submit')

    assert_selector 'div#error_explanation > ul > li', text: 'Your card was declined'
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

    assert_selector 'div#error_explanation > ul > li', text: 'We are unable to authenticate your payment method. Please choose a different payment method and try again.'
  end

  test '#new - requires 3D secure check that passes' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4000000000003220'
    click_button I18n.t('app.get_breaded.payment.submit')

    complete_stripe_sca_with 'Complete'

    # TODO add final screen
  end

  test '#new' do
    visit new_subscription_payment_path(@subscription, shopping_basket_variant: Orders::UpdateFromBasket::PICK_UP_TYPE)

    fill_stripe_elements card: '4242424242424242'
    click_button I18n.t('app.get_breaded.payment.submit')

    # TODO add final screen
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

  def add_new_stripe_product!
    Stripe::UpdateSubscriptionPlanJob.perform_now @subscription.subscription_plan
  end
end
