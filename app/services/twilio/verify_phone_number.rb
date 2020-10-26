# frozen_string_literal: true

class Twilio::VerifyPhoneNumber
  attr_accessor :user, :phone_number, :errors

  DELAY_BETWEEN_SMS = 5 # minutes

  def initialize(user, phone_number)
    @user = user
    @phone_number = phone_number
    @errors = []
  end

  def send
    return if too_many_requests? || !valid_number?

    send_sms
    user.update! unconfirmed_phone: phone_number, phone_confirmation_token: random_number, phone_confirmation_sent_at: Time.current
  rescue Phony::NormalizationError, Twilio::REST::RestError => e
    errors << I18n.t('app.twilio.phone_verification.invalid_number')
  end

  private

  def valid_number?
    self.phone_number = Phony.normalize phone_number
    errors << I18n.t('app.twilio.phone_verification.invalid_number') unless Phony.plausible?(phone_number)
    errors.blank?
  end

  def too_many_requests?
    return false if user.phone_confirmation_sent_at.blank?

    minutes = ((Time.current - user.phone_confirmation_sent_at) / 60).ceil
    time_diff = DELAY_BETWEEN_SMS - minutes
    errors << I18n.t('app.twilio.phone_verification.too_many_requests', minutes: time_diff, count: time_diff) if minutes < DELAY_BETWEEN_SMS
    !errors.blank?
  end

  def send_sms
    client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])
    client.messages.create(body: message, from: ENV['TWILIO_PHONE_NUMBER'], to: '+' + phone_number)
  end

  def random_number
    @random_number ||= SecureRandom.random_number.to_s[2..7]
  end

  def message
    @message ||= I18n.t('app.twilio.phone_verification.message', code: random_number)
  end
end
