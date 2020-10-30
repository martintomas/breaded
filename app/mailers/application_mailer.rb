# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@breaded.net'
  layout 'mailer'
end
