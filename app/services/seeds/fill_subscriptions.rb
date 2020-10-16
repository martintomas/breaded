# frozen_string_literal: true

class Seeds::FillSubscriptions
  def self.perform_for(subscriptions)
    subscriptions.each do |subscription|
      next if Subscription.joins(:user).where(active: subscription[:active], users: { email: subscription[:user] }).exists?

      puts "subscription: #{subscription[:user]} - #{subscription[:active]}"
      subscription_obj = Subscription.new subscription_plan: subscription_plan_for(subscription[:subscription_plan]),
                                          user: User.find_by!(email: subscription[:user]),
                                          active: subscription[:active],
                                          number_of_orders_left: subscription[:number_of_orders_left],
                                          number_of_items: Rails.application.config.options[:default_number_of_breads]
      build_surprises_for subscription_obj, subscription[:surprises]
      build_payments_for subscription_obj, subscription[:payments]
      subscription_obj.save!
    end
  end

  def self.subscription_plan_for(values)
    SubscriptionPlan.joins(:currency).find_by! price: values[:price], currencies: { code: values[:currency] }
  end

  def self.build_surprises_for(subscription, values)
    return if values.blank?

    values.each do |surprise|
      tag = Tag.joins(name: :text_translations).find_by! text_translations: { text: surprise[:tag][:name] }, tag_type: surprise[:tag][:tag_type]
      subscription.subscription_surprises.build tag: tag, amount: surprise[:amount]
    end
  end

  def self.build_payments_for(subscription, values)
    values.each do |payment|
      subscription.payments.build price: payment[:price],
                                  currency: Currency.find_by!(code: payment[:currency])
    end
  end
end
