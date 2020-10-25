# frozen_string_literal: true

module Subscriptions
  class NewSubscriptionFormer
    include ActiveModel::Model

    attr_accessor :subscription, :address, :subscription_plan_id, :delivery_date_from, :delivery_date_to, :address_line,
                  :street, :city, :postal_code, :shopping_basket_variant, :user, :basket_items

    validates :subscription_plan_id, :delivery_date_from, :delivery_date_to, :street, :city,
              :postal_code, :shopping_basket_variant, :basket_items, :user, presence: true

    def initialize(attributes = {})
      super attributes
      self.delivery_date_from ||= 1.hour.from_now # TODO - remove after calendar is ready
      self.delivery_date_to ||= 3.hour.from_now # TODO - remove after calendar is ready
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
      super && valid_delivery_dates? && valid_user? && valid_address? && valid_subscription? && valid_basket?

      errors.blank?
    end

    private

    def process_subscription
      subscription.save!
      address.save!
      run_subscriber!
    end

    def run_subscriber!
      subscriber = Subscriptions::Subscribe.new subscription, delivery_date: delivery_date_from
      order = subscriber.perform.sort_by(&:delivery_date_from).first
      Orders::UpdateFromBasket.new(order, basket_items).perform_for shopping_basket_variant
      order.create_address user.address.attributes.slice('address_line', 'street', 'postal_code', 'city', 'state', 'address_type_id')
    end

    def valid_user?
      errors.add(:base, :already_active_subscription) if user.subscriptions.where(active: true).exists?

      errors.blank?
    end

    def valid_address?
      address_params = { address_type_id: AddressType.the_personal.id, address_line: address_line, street: street,
                         city: city, postal_code: postal_code, state: 'UK' }
      self.address = user.address.present? ? user.address : user.addresses.new
      address.assign_attributes address_params
      address.valid? || promote_errors(address.errors)
    end

    def valid_delivery_dates?
      self.delivery_date_from = Time.zone.parse(delivery_date_from) if delivery_date_from.is_a? String
      self.delivery_date_to = Time.zone.parse(delivery_date_to) if delivery_date_to.is_a? String
      # TODO - add after calendar will be finished
      true
    end

    def valid_basket?
      self.basket_items = JSON.parse(basket_items).map(&:deep_symbolize_keys)
      BasketItemsValidator.new(self, basket_items).run_validations_for shopping_basket_variant
    end

    def valid_subscription?
      self.subscription = Subscription.new subscription_plan: SubscriptionPlan.find_by_id(subscription_plan_id),
                                           user: user,
                                           active: false,
                                           number_of_items: Rails.application.config.options[:default_number_of_breads]
      subscription.valid? || promote_errors(subscription.errors)
    end

    def promote_errors(child_errors)
      child_errors.each { |attribute, message| errors.add(attribute, message) }
    end

    def preload_address
      return if user&.address.blank?

      self.address_line ||= user.address.address_line
      self.street ||= user.address.street
      self.city ||= user.address.city
      self.postal_code ||= user.address.postal_code
    end
  end
end
