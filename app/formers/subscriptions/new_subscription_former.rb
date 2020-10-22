# frozen_string_literal: true

module Subscriptions
  class NewSubscriptionFormer
    include ActiveModel::Model

    attr_accessor :subscription, :subscription_plan_id, :delivery_date_from, :delivery_date_to, :address_line, :street,
                  :city, :postal_code, :shopping_basket_variant, :user, :basket_items

    validates :subscription_plan_id, :delivery_date_from, :delivery_date_to, :street, :city,
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
        process_subscription
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.blank?
    end

    def valid?
      super && valid_address? && valid_subscription? && valid_basket?

      errors.blank?
    end

    private

    def process_subscription
      subscription.save!
      user.address.save!
      run_subscriber!
    end

    def run_subscriber!
      subscriber = Subscriptions::Subscribe.new subscription, delivery_date: delivery_date_from
      orders = subscriber.perform
      Orders::UpdateFromBasket.new(orders.sort_by(&:delivery_date_from).first, basket_items).perform_for shopping_basket_variant
      subscriber.errors.each { |e| errors << e }
    end

    def valid_address?
      address_params = { address_line: address_line, street: street, city: city, postal_code: postal_code, state: 'UK' }
      user.address.present? ? user.address.assign_attributes(address_params) : user.build_address(address_params)
      user.address.valid? || promote_errors(user.address.errors)
    end

    def valid_basket?
      self.basket_items = JSON.parse(basket_items).map(&:deep_symbolize_keys)
      BasketItemValidator.new(self, basket_items).run_validations_for shopping_basket_variant
    end

    def valid_subscription?
      subscription = Subscription.new subscription_plan: SubscriptionPlan.find_by_id(subscription_plan_id),
                                      user: user,
                                      active: true,
                                      number_of_items: Rails.application.config.options[:default_number_of_breads]
      subscription.valid? || promote_errors(subscription.errors)
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
