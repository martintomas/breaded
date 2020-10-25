# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  protect_from_forgery with: :exception, except: :subscription_webhook

  before_action :set_locale

  private

  def set_admin_timezone
    Time.zone = 'London'
  end

  def set_locale
    # TODO: refactor at future
    I18n.locale = :en
  end
end
