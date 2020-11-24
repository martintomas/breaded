# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order
  before_action :set_copied_order, only: :copy_order_option

  def show
    authorize! :read, @order
  end

  def edit
    authorize! :update, @order
  end

  def confirm_update
    authorize! :update, @order

    @order_former = Orders::UpdateFormer.new order: @order, shopping_basket_variant: params[:shopping_basket_variant]
  end

  def update
    authorize! :update, @order

    @order_former = Orders::UpdateFormer.new order_former_params.merge(order: @order).merge(order_params)
    if @order_former.save
      redirect_to subscription_period_path(@order.subscription_period)
    else
      render :confirm_update
    end
  end

  def pick_breads_option
    authorize! :update, @order
    raise CanCan::AccessDenied if @order.finalised?

    @order.update! copied_order: nil, unconfirmed_copied_order: nil
    OrderStateRelation.find_by(order: @order, order_state: OrderState.the_order_placed).destroy if @order.placed?
    render json: { order_detail: render_to_string(partial: 'subscription_periods/show/order_editable',
                                                  locals: { order: preloaded_order_detail_for(@order.id) }, formats: [:html]) }
  end

  def copy_order_option
    authorize! :update, @order
    authorize! :read, @copied_order
    raise CanCan::AccessDenied if @order.finalised?

    if @order.copied_order == @copied_order
      @order.update! unconfirmed_copied_order: nil
    else
      @order.update! unconfirmed_copied_order: @copied_order
    end
    render json: { order_detail: render_to_string(partial: 'subscription_periods/show/order_editable',
                                                  locals: { order: preloaded_order_detail_for(@order.id) }, formats: [:html]) }
  end

  def confirm_copy_option
    authorize! :update, @order
    raise CanCan::AccessDenied if @order.finalised?

    @order.update! copied_order: @order.unconfirmed_copied_order, unconfirmed_copied_order: nil
    Orders::Copy.new(@order, @order.copied_order).perform
    @order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id unless @order.placed?
    render json: { order_detail: render_to_string(partial: 'subscription_periods/show/order_editable',
                                                  locals: { order: preloaded_order_detail_for(@order.id) }, formats: [:html]) }
  end

  def update_date
    authorize! :update, @order

    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(time: Time.zone.parse(params[:timestamp])).find
    @order.update! delivery_date_from: delivery_date_from, delivery_date_to: delivery_date_to
    render json: { delivery_date: @order.delivery_date_from.strftime('%A %d %b'),
                   delivery_date_range: "#{@order.delivery_date_from.strftime('%l:%M %P')} - #{@order.delivery_date_to.strftime('%l:%M %P')}" }
  end

  def update_address
    authorize! :update, @order

    puts address_params.inspect
    address = @order.address || @order.build_address
    address.assign_attributes address_params
    address.save!
    render json: { address_line: address.address_line, street: address.street, city: address.city, postal_code: address.postal_code }
  end

  def surprise_me
    authorize! :read, @order
  end

  private

  def preloaded_order_detail_for(id)
    Order.preload(:order_states, subscription_period: { orders: :order_states }).find id
  end

  def set_order
    @order = Order.find params[:id]
  end

  def set_copied_order
    @copied_order = Order.find params[:copy_order_id]
  end

  def order_former_params
    params.require(:orders_update_former).permit(:delivery_date_from, :address_line, :street, :city, :postal_code,
                                                 :phone_number, :secondary_phone_number, :shopping_basket_variant)
  end

  def order_params
    params.permit(:basket_items)
  end

  def address_params
    params.require(:address).permit(:address_line, :street, :city, :postal_code)
  end
end
