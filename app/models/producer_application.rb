# frozen_string_literal: true

class ProducerApplication < ApplicationRecord
  has_one :producer, dependent: :nullify
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags

  validates :first_name, :last_name, :email, :phone_number, presence: true

  accepts_nested_attributes_for :entity_tags
end
