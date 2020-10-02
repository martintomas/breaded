# frozen_string_literal: true

class ProducerApplicationsController < ApplicationController
  def new
    @producer_application = ProducerApplication.new
  end

  def create
    params = producer_application_params.to_h
    params[:entity_tags_attributes] = params.delete(:tag_ids).reject(&:blank?).map { |tag_id| { tag_id: tag_id  } }
    @producer_application = ProducerApplication.new params

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
