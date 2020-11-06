# frozen_string_literal: true

class TwilioController < ApplicationController
  def sent_verification_sms
    twilio_service = Twilio::VerifyPhoneNumber.new(current_user, params[:phone_number])
    twilio_service.send

    render json: { errors: twilio_service.errors, response: {}}.to_json
  end

  def verify_phone_number
    errors = []
    if current_user.phone_confirmation_token == params[:phone_token]
      current_user.update! phone_number: current_user.unconfirmed_phone
    else
      errors << I18n.t('app.twilio.phone_verification.invalid_phone_token')
    end
    render json: { errors: errors, response: {}}.to_json
  end
end
