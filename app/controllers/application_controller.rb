# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  protect_from_forgery with: :exception, except: :subscription_webhook

  before_action :authenticate_user!
  before_action :set_locale

  private

  def set_locale
    # TODO: refactor at future
    I18n.locale = :en
  end

  def current_ability
    @current_ability ||= current_user&.current_ability.presence || Ability.new(nil)
  end
end
