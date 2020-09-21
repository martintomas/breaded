# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :recoverable, :rememberable, :validatable, :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable
  rolify

  has_many :subscriptions, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
  has_one :address, as: :addressable, dependent: :destroy

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true
end
