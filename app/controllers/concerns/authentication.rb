# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    rescue_from CanCan::AccessDenied do |exception|
      access_denied exception
    end
  end

  def access_denied(exception)
    respond_to do |format|
      format.json { head :forbidden, content_type: 'text/html' }
      format.html { redirect_to main_app.root_url, notice: exception.message }
      format.js   { head :forbidden, content_type: 'text/html' }
    end
  end

  def authenticate_admin_user!
    authenticate_user!
    authorize! :access_admin, current_user
  end
end
