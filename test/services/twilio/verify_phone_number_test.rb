# frozen_string_literal: true

require 'test_helper'
require 'mocks/twilio'

class Twilio::VerifyPhoneNumberTest < ActiveSupport::TestCase
  include Mocks::Twilio

  setup do
    @user = users :customer
    @random_number = 123456
  end

  test '#send - empty number' do
    service = Twilio::VerifyPhoneNumber.new(@user, '')
    service.send
    assert_equal [I18n.t('app.twilio.phone_verification.invalid_number')], service.errors
  end

  test '#send - not valid number' do
    service = Twilio::VerifyPhoneNumber.new(@user, '123456789')
    service.send
    assert_equal [I18n.t('app.twilio.phone_verification.invalid_number')], service.errors
  end

  test '#send - too many requests' do
    @user.update! phone_confirmation_sent_at: Time.current - 10.seconds
    service = Twilio::VerifyPhoneNumber.new(@user, '+420734370408')
    service.send
    delay = Twilio::VerifyPhoneNumber::DELAY_BETWEEN_SMS - 1
    assert_equal [I18n.t('app.twilio.phone_verification.too_many_requests', minutes: delay, count: delay)], service.errors
  end

  test '#send - sends sms when phone number is valid' do
    frozen_time = Time.current
    expected_message = { body: I18n.t('app.twilio.phone_verification.message', code: @random_number),
                         from: ENV['TWILIO_PHONE_NUMBER'],
                         to: '+420734370408' }
    travel_to frozen_time do
      Twilio::VerifyPhoneNumber.stub_any_instance :random_number, @random_number do
        Twilio::REST::Client.stub :new, mock_twilio_for(expected_message) do
          service = Twilio::VerifyPhoneNumber.new(@user, '+420734370408')
          service.send

          @user.reload
          assert_empty service.errors
          assert_equal '+420734370408', @user.unconfirmed_phone
          assert_equal @random_number.to_s, @user.phone_confirmation_token
          assert_equal frozen_time.to_i, @user.phone_confirmation_sent_at.to_i
        end
      end
    end
  end

  test '#send - sends sms when phone number is valid and time from last request was already crossed' do
    @user.update! phone_confirmation_sent_at: Time.current - Twilio::VerifyPhoneNumber::DELAY_BETWEEN_SMS.minutes
    Twilio::VerifyPhoneNumber.stub_any_instance :random_number, @random_number do
      Twilio::REST::Client.stub :new, mock_twilio_for do
        service = Twilio::VerifyPhoneNumber.new(@user, '+420734370408')
        service.send

        @user.reload
        assert_empty service.errors
        assert_equal '+420734370408', @user.unconfirmed_phone
        assert_equal @random_number.to_s, @user.phone_confirmation_token
      end
    end
  end
end
