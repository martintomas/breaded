# frozen_string_literal: true

require 'test_helper'
require 'mocks/twilio'

class TwilioControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  include Mocks::Twilio

  setup do
    @user = users :customer
    sign_in @user
  end

  test '#sent_verification_sms - when error occurs' do
    post sent_verification_sms_twilio_index_path, params: { phone_number: '' }

    assert_response :success

    @user.reload
    body = JSON.parse(response.body).symbolize_keys
    assert_equal [I18n.t('app.twilio.phone_verification.invalid_number')], body[:errors]
    assert_nil @user.unconfirmed_phone
  end

  test '#sent_verification_sms - sms is send successfully' do
    Twilio::REST::Client.stub :new, mock_twilio_for do
      post sent_verification_sms_twilio_index_path, params: { phone_number: '+420734370407' }

      assert_response :success

      @user.reload
      body = JSON.parse(response.body).symbolize_keys
      assert_empty body[:errors]
      assert_equal '+420734370407', @user.unconfirmed_phone
    end
  end

  test '#verify_phone_number - phone_token match' do
    @user.update! unconfirmed_phone: '+420123456789', phone_confirmation_token: '123456'

    post verify_phone_number_twilio_index_path, params: { phone_token: '123456' }

    assert_response :success

    @user.reload
    body = JSON.parse(response.body).symbolize_keys
    assert_empty body[:errors]
    assert_equal '+420123456789', @user.phone_number
  end

  test '#verify_phone_number - phone_token does not match' do
    @user.update! unconfirmed_phone: '+420123456789', phone_confirmation_token: '123456'

    post verify_phone_number_twilio_index_path, params: { phone_token: '11111' }

    assert_response :success

    @user.reload
    body = JSON.parse(response.body).symbolize_keys
    assert_equal [I18n.t('app.twilio.phone_verification.invalid_phone_token')], body[:errors]
    refute_equal '+420123456789', @user.phone_number
  end
end
