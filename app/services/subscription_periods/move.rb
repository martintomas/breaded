# frozen_string_literal: true

class SubscriptionPeriods::Move
  attr_accessor :subscription_period, :time

  def initialize(subscription_period, to:)
    @subscription_period = subscription_period
    @time = to
  end

  def perform
    return unless require_postpone?

    move_subscriptions_period
  end

  private

  def move_subscriptions_period
    delivery_date = time
    subscription_periods.each do |subscription_period|
      move subscription_period, to: delivery_date
      delivery_date += 1.month
    end
  end

  def move(subscription_period, to:)
    subscription_period.started_at = subscription_period.started_at.change year: to.year, month: to.month, day: to.day
    subscription_period.ended_at = subscription_period.started_at + 1.month
    subscription_period.save!

    move_orders_of subscription_period
  end

  def move_orders_of(subscription_period)
    subscription_period.orders.sort_by(&:delivery_date_from).inject(nil) do |prev_order, order|
      move_of order, by: week_diff_between(subscription_period, order, prev_order)
      order
    end
  end

  def move_of(order, by:)
    delivery_date_from = order.delivery_date_from + by.weeks
    delivery_date_from, delivery_date_to = Availabilities::FirstSuitable.new(time: delivery_date_from).find
    order.update! delivery_date_from: delivery_date_from, delivery_date_to: delivery_date_to
  end

  def week_diff_between(subscription_period, order, prev_order)
    return order.delivery_date_from.to_date.step(subscription_period.started_at.to_date, 7).count if prev_order.blank?

    order.delivery_date_from.to_date.step(prev_order.delivery_date_from.to_date, 7).count
  end

  def subscription_periods
    @subscription_periods ||= begin
      SubscriptionPeriod.includes(:orders).where(subscription: subscription_period.subscription, paid: false)
        .where('started_at >= ?', subscription_period.started_at).order(:started_at)
    end
  end

  def require_postpone?
    subscription_period.orders.any? { |order| order.delivery_date_from.to_date <= time }
  end
end
