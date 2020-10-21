# frozen_string_literal: true

class Seeds::FillSubscriptions
  def self.perform_for(subscriptions)
    subscriptions.each do |subscription|
      next if Subscription.joins(:user).where(active: subscription[:active], users: { email: subscription[:user] }).exists?

      puts "subscription: #{subscription[:user]} - #{subscription[:active]}"
      subscription_obj = Subscription.new subscription_plan: subscription_plan_for(subscription[:subscription_plan]),
                                          user: User.find_by!(email: subscription[:user]),
                                          active: subscription[:active],
                                          number_of_items: Rails.application.config.options[:default_number_of_breads]
      build_subscription_period_for subscription_obj, subscription[:periods]
      build_payments_for subscription_obj, subscription[:payments]
      subscription_obj.save!
    end
  end

  def self.subscription_plan_for(values)
    SubscriptionPlan.joins(:currency).find_by! price: values[:price], currencies: { code: values[:currency] }
  end

  def self.build_subscription_period_for(subscription, values)
    values.each do |period|
      subscription.subscription_periods.build started_at: period[:started_at], ended_at: period[:ended_at]
    end
  end

  def self.build_payments_for(subscription, values)
    values.each do |payment|
      subscription.subscription_periods.first.payments.build price: payment[:price],
                                                             currency: Currency.find_by!(code: payment[:currency])
    end
  end
end
