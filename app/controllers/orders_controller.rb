# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order
  before_action :set_copied_order, only: :copy

  def show
    authorize! :read, @order
  end

  def edit
    authorize! :update, @order
  end

  def update
    authorize! :update, @order
    return redirect_to subscription_period_path(@order.subscription_period) if @order.placed?

    Orders::UpdateFromBasket.new(@order, JSON.parse(params[:basket_items]).map(&:deep_symbolize_keys)).perform_for params[:shopping_basket_variant]
    @order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id
    redirect_to subscription_period_path(@order.subscription_period)
  end

  def copy
    authorize! :update, @order
    authorize! :read, @copied_order
    raise CanCan::AccessDenied if @order.placed?

    Orders::Copy.new(@order, @copied_order).perform
    @order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id
    render json: { order_detail: render_to_string(partial: 'subscription_periods/show/order_detail',
                                                  locals: { order: @order, orders: @order.subscription_period.orders.order(:delivery_date_from) },
                                                  formats: [:html]) }
  end

  def update_date
    authorize! :update, @order

    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(time: Time.zone.parse(params[:timestamp])).find
    @order.update! delivery_date_from: delivery_date_from, delivery_date_to: delivery_date_to
    render json: { delivery_date: @order.delivery_date_from.strftime('%A %d %b'),
                   delivery_date_range: "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}" }
  end

  def surprise_me
    authorize! :read, @order
  end

  private

  def set_order
    @order = Order.find params[:id]
  end

  def set_copied_order
    @copied_order = Order.find params[:copy_order_id]
  end
end
