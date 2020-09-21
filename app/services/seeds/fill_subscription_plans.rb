class Seeds::FillSubscriptionPlans
  def self.perform_for(subscription_plans)
    subscription_plans.each do |subscription_plan|
      subscription_plan[:currency] = Currency.find_by code: subscription_plan[:currency]
      next if SubscriptionPlan.where(subscription_plan).exists?

      puts "subscription plan for: #{subscription_plan[:currency].code} - #{subscription_plan[:price]}"
      SubscriptionPlan.create! subscription_plan
    end
  end
end
