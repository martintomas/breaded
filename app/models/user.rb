# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :rememberable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :confirmable, :registerable, :validatable
  rolify

  has_many :subscriptions, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
  has_one :address, as: :addressable, dependent: :destroy

  validates :first_name, :last_name, presence: true

  def current_ability
    @current_ability ||= Ability.new self
  end
end
