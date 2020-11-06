# frozen_string_literal: true

class ProducerApplicationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @producer_application = ProducerApplication.new

    authorize! :create, @producer_application
  end

  def create
    @producer_application = ProducerApplication.new producer_application_params
    authorize! :create, @producer_application

    if @producer_application.save
      redirect_to new_producer_application_path, notice: I18n.t('app.baker_signup.notice')
    else
      render new_producer_application_path
    end
  end

  private

  def producer_application_params
    params.require(:producer_application).permit(:first_name, :last_name, :email, :phone_number, tag_ids: [])
  end
end
