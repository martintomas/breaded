# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :rememberable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :confirmable, :registerable, :validatable
  rolify

  attr_accessor :skip_stripe_sync

  phony_normalize :phone_number, :unconfirmed_phone, default_country_code: 'UK'
  phony_normalized_method :phone_number, :unconfirmed_phone

  has_many :subscriptions, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
  has_many :addresses, as: :addressable, dependent: :destroy

  accepts_nested_attributes_for :addresses

  validates :first_name, :last_name, presence: true
  validates :phone_number, :unconfirmed_phone, phony_plausible: true

  after_save :stripe_sync, unless: :skip_stripe_sync

  def current_ability
    @current_ability ||= Ability.new self
  end

  def address
    addresses.detect(&:main?) || addresses.first
  end

  def to_s
    "#{first_name} #{last_name} (#{email})"
  end

  private

  def stripe_sync
    Stripe::UpdateCustomerJob.perform_later self
  end
end
