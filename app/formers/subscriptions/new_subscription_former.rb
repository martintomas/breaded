# frozen_string_literal: true

module Subscriptions
  class NewSubscriptionFormer
    include ActiveModel::Model

    PICK_UP_TYPE = 'pick-up'.freeze
    SURPRISE_ME_TYPE = 'surprise-me'.freeze

    attr_accessor :subscription_plan_id, :stripe_token, :delivery_date_from, :delivery_date_to, :address_line, :street,
                  :city, :postal_code, :shopping_basket_variant, :user, :basket_items, :basket_items_parsed

    validates :subscription_plan_id, :stripe_token, :delivery_date_from, :delivery_date_to, :address_line, :street, :city,
              :postal_code, :shopping_basket_variant, :basket_items, :user, presence: true

    def initialize(attributes = {})
      super attributes
      self.delivery_date_from = 1.hour.from_now
      self.delivery_date_to = 3.hour.from_now
      preload_address
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        user.address.save!
        subscription = save_subscription!
        charge_user_for! subscription
        save_order_for! subscription
        errors.blank?
      end
    rescue ActiveRecord::RecordNotFound, ActiveModel::ValidationError => e
      errors.add :base, e.message
      false
    end

    def valid?
      super && valid_address? && valid_basket?

      errors.blank?
    end

    private

    def valid_address?
      address_params = { address_line: address_line, street: street, city: city, postal_code: postal_code, state: 'UK' }
      user.address.present? ? user.address.assign_attributes(address_params) : user.build_address(address_params)
      user.address.valid? || promote_errors(user.address.errors)
    end

    def valid_basket?
      self.basket_items_parsed = JSON.parse(basket_items).map(&:deep_symbolize_keys)
      validate_pick_up_items! if shopping_basket_variant == PICK_UP_TYPE
    end

    def validate_pick_up_items!
      num_of_items = basket_items_parsed.sum { |item| item[:amount].to_i }
      return errors.add(:base, :missing_items) unless num_of_items == Rails.application.config.options[:default_number_of_breads]

      available_foods = Food.enabled.pluck(:id)
      basket_items_parsed.map do |item|
        errors.add(:base, :missing_food_item, name: item[:name]) unless item[:id].in? available_foods
      end
    end

    def save_subscription!
      subscription_plan = SubscriptionPlan.find subscription_plan_id
      subscription = Subscription.new subscription_plan: subscription_plan,
                                      user: user,
                                      active: true,
                                      number_of_items: Rails.application.config.options[:default_number_of_breads]
      add_surprise_me_tags_to(subscription) if shopping_basket_variant == SURPRISE_ME_TYPE
      subscription.tap { |s| s.save! }
    end

    def add_surprise_me_tags_to(subscription)
      basket_items_parsed.map do |item|
        subscription.subscription_surprises.build amount: item[:amount], tag_id: item[:id]
      end
    end
    
    def save_order_for!(subscription)
      return unless errors.blank?
      return Orders::PredictJob.perform_later subscription, delivery_date_from, delivery_date_to if shopping_basket_variant == SURPRISE_ME_TYPE

      order = Order.new subscription: subscription, user: user, delivery_date_from: delivery_date_from,
                        delivery_date_to: delivery_date_to
      basket_items_parsed.each { |item| order.order_foods.build food_id: item[:id], automatic: false, amount: item[:amount] }
      order.build_address user.address.attributes.slice('address_line', 'street', 'city', 'postal_code', 'state')
      order.save!
    end

    def charge_user_for!(subscription)
      return unless errors.blank?

      charger = PaymentMethods::Charger.new user, subscription.subscription_plan, stripe_token
      charger.charge!
      errors.add(:base, charger.error) if charger.error.present?
    end

    def promote_errors(child_errors)
      child_errors.each do |attribute, message|
        errors.add(attribute, message)
      end
    end

    def preload_address
      return if user.address.blank?

      self.address_line = user.address.address_line
      self.street = user.address.street
      self.city = user.address.city
      self.postal_code = user.address.postal_code
    end
  end
end
