# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: %i[update_date copy show]

  def show; end

  def copy
    service = Orders::Copy.new @order, Order.find(params[:copy_order_id])
    if service.perform
      redirect_to subscription_period_path(@order.subscription_period)
    else
      @subscription_period = @order.subscription_period
      render 'subscription_periods/show', notice: service.errors.join(',')
    end
  end

  def update_date
    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(time: Time.zone.parse(params[:timestamp])).find
    @order.update! delivery_date_from: delivery_date_from, delivery_date_to: delivery_date_to
    render json: { delivery_date: @order.delivery_date_from.strftime('%A %d %b'),
                   delivery_date_range: "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}" }
  end

  private

  def set_order
    @order = Order.find params[:id]
  end
end
