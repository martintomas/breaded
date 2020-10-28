# frozen_string_literal: true

class Subscriptions::MarkAsPaid
  attr_accessor :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  def perform
    subscription_period.update! paid: true
    subscription_period.payments.create! price: subscription.subscription_plan.price, currency: subscription.subscription_plan.currency
    SubscriptionPeriods::Move.new(subscription_period, to: Time.current).perform
  end

  private

  def subscription_period
    @subscription_period ||= begin
      subscription.subscription_periods.where(paid: false).where('ended_at >= ?', Time.current).order(:ended_at).first ||
        prepare_new_subscription_period!
    end
  end

  def prepare_new_subscription_period!
    subscriber = Subscriptions::Subscribe.new subscription
    subscriber.perform
    subscriber.subscription_period
  end
end
