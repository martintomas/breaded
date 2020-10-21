# frozen_string_literal: true

class Subscriptions::Subscribe
  attr_accessor :subscription, :delivery_date, :token, :errors

  def initialize(subscription, delivery_date: nil, token: nil)
    @subscription = subscription
    @delivery_date = delivery_date || first_available_delivery_date
    @token = token
    @errors = []
  end

  def perform
    ActiveRecord::Base.transaction do
      orders = create_orders_for create_subscription_period!
      yield(orders) if has_block?
      charge!
      raise ActiveRecord::Rollback if errors.present?
    end
  end

  private

  def create_subscription_period!
    return if errors.present?

    subscription.subscription_periods.create! started_at: delivery_date, ended_at: delivery_date + 1.month
  end

  def create_orders_for(subscription_period)
    return if errors.present?

    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(delivery_date).find
    number_of_deliveries = subscription.subscription_plan.number_of_deliveries

    number_of_deliveries.times.map do |i|
      week_modification = i * (4 / number_of_deliveries)
      create_order_for! subscription_period, week_modification, delivery_date_from, delivery_date_to
    end
  end

  def charge!
    return if errors.present?

    charger = PaymentMethods::Charger.new(subscription.user, subscription.subscription_plan, token: token)
    charger.charge!
    errors << charger.error if charger.error.present?
  end

  def create_order_for!(subscription_period, week_modification, delivery_date_from, delivery_date_to)
    order = subscription_period.orders.build user: subscription.user,
                                             delivery_date_from: delivery_date_from + week_modification.weeks,
                                             delivery_date_to: delivery_date_to + week_modification.weeks
    order.order_state_relations.build order_state: OrderState.the_new
    order.build_address order.user.address.attributes.slice('address_line', 'street', 'postal_code', 'city', 'state', 'address_type_id')
    order.tap { |o| o.save! }
  end

  def first_available_delivery_date
    last_active_date = subscription.subscription_periods.order(:ended_at).first&.ended_at
    return Time.current if last_active_date.blank?

    last_active_date.change year: Time.current.year, month: Time.current.month, day: Time.current.day
  end
end
