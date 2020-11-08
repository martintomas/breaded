# frozen_string_literal: true

class Subscriptions::Subscribe
  attr_accessor :subscription, :subscription_period, :delivery_date_subscription, :delivery_date_order

  def initialize(subscription, delivery_date: nil)
    @subscription = subscription
    @delivery_date_subscription = delivery_date || subscription_delivery_date
    @delivery_date_order = delivery_date || order_delivery_date
  end

  def perform
    create_orders_for create_subscription_period!
  end

  private

  def create_subscription_period!
    self.subscription_period = SubscriptionPeriod.create! subscription: subscription,
                                                          started_at: delivery_date_subscription,
                                                          ended_at: delivery_date_subscription + 1.month
  end

  def create_orders_for(subscription_period)
    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(time: delivery_date_order).find
    number_of_deliveries = subscription.subscription_plan.number_of_deliveries

    number_of_deliveries.times.map do |i|
      week_modification = i * (4 / number_of_deliveries)
      create_order_for! i, subscription_period, week_modification, delivery_date_from, delivery_date_to
    end
  end

  def create_order_for!(position, subscription_period, week_modification, delivery_date_from, delivery_date_to)
    order = subscription_period.orders.build user: subscription.user,
                                             delivery_date_from: delivery_date_from + week_modification.weeks,
                                             delivery_date_to: delivery_date_to + week_modification.weeks,
                                             position: position
    order.order_state_relations.build order_state_id: OrderState.the_new.id
    order.tap { |o| o.save! }
  end

  def subscription_delivery_date
    last_active_date = subscription.subscription_periods.order(:ended_at).last&.ended_at
    return Time.current if last_active_date.blank?
    return last_active_date if last_active_date >= Time.current

    last_active_date.change year: Time.current.year, month: Time.current.month, day: Time.current.day
  end

  def order_delivery_date
    last_order_date = subscription.orders.order(:delivery_date_from).last&.delivery_date_from
    return subscription_delivery_date if last_order_date.blank?

    week_diff = last_order_date.to_date.step(subscription_delivery_date.to_date, 7).count
    last_order_date + week_diff.weeks
  end
end
