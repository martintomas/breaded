# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :rememberable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :confirmable, :registerable, :validatable
  rolify

  phony_normalize :phone_number, :unconfirmed_phone, :secondary_phone_number, default_country_code: 'UK'
  phony_normalized_method :phone_number, :unconfirmed_phone, :secondary_phone_number

  has_many :subscriptions, dependent: :restrict_with_exception
  has_many :subscription_periods, through: :subscriptions
  has_many :orders, dependent: :restrict_with_exception
  has_many :addresses, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :addresses

  validates :first_name, :last_name, presence: true
  validates :phone_number, :unconfirmed_phone, :secondary_phone_number, phony_plausible: true

  after_save :stripe_sync, if: :saved_change_to_email?

  def current_ability
    @current_ability ||= Ability.new self
  end

  def address
    addresses.detect(&:main?) || addresses.first
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def payment_method
    return if stripe_customer.blank?

    @payment_method ||= begin
      Stripe::Customer.retrieve(id: stripe_customer, expand: ['invoice_settings.default_payment_method'])
        .invoice_settings.default_payment_method
    end
  end

  def to_s
    "#{first_name} #{last_name} (#{email})"
  end

  private

  def stripe_sync
    Stripe::UpdateCustomerJob.perform_later self
  end
end
