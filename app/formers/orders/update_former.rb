# frozen_string_literal: true

module Orders
  class UpdateFormer
    include ActiveModel::Model

    attr_accessor :order, :user, :delivery_date_from, :address_line, :street, :city, :postal_code, :shopping_basket_variant,
                  :phone_number, :secondary_phone_number, :address, :basket_items

    validates :delivery_date_from, :street, :city, :postal_code, :shopping_basket_variant, :basket_items, :order, presence: true

    def initialize(attributes = {})
      super attributes
      preload_user
      preload_order
      preload_address
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        process_order
        raise ActiveRecord::Rollback if errors.present?
      end
      errors.blank?
    end

    def valid?
      super && valid_delivery_dates? && valid_user? && valid_address? && valid_basket?

      errors.blank?
    end

    private

    def process_order
      address.save!
      user.save!
      update_order!
    end

    def update_order!
      from, to = Availabilities::FirstSuitable.new(time: delivery_date_from).find
      order.update! delivery_date_from: from, delivery_date_to: to
      Orders::UpdateFromBasket.new(order, basket_items).perform_for shopping_basket_variant
      order.order_state_relations.create! order_state_id: OrderState.the_order_placed.id unless order.placed?
    end

    def valid_user?
      errors.add(:phone_number, :not_valid) if user.phone_number.blank?
      user.secondary_phone_number = secondary_phone_number
      user.valid? || promote_errors(user.errors)
    end

    def valid_address?
      address_params = { address_type_id: AddressType.the_personal.id, address_line: address_line, street: street,
                         city: city, postal_code: postal_code, state: 'UK' }
      self.address = order.address.presence || order.build_address
      address.assign_attributes address_params
      address.valid? || promote_errors(address.errors)
    end

    def valid_delivery_dates?
      self.delivery_date_from = Time.zone.parse(delivery_date_from) if delivery_date_from.is_a? String
      errors.add(:delivery_date_from, :invalid_date) unless Availability.available_at? delivery_date_from
      errors.blank?
    end

    def valid_basket?
      self.basket_items = JSON.parse(basket_items).map(&:deep_symbolize_keys)
      BasketItemsValidator.new(self, basket_items).run_validations_for shopping_basket_variant
    end

    def promote_errors(child_errors)
      child_errors.each { |attribute, message| errors.add(attribute, message) }
    end

    def preload_user
      self.user ||= order.user
      self.phone_number ||= user.phone_number
      self.secondary_phone_number ||= user.secondary_phone_number
    end

    def preload_order
      self.delivery_date_from ||= order.delivery_date_from
    end

    def preload_address
      address = order.address.presence || user.address
      return if address.blank?

      self.address_line ||=address.address_line
      self.street ||= address.street
      self.city ||= address.city
      self.postal_code ||= address.postal_code
    end
  end
end
