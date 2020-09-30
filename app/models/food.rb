# frozen_string_literal: true

class Food < ApplicationRecord
  belongs_to :producer
  belongs_to :name, class_name: 'LocalisedText'
  belongs_to :description, class_name: 'LocalisedText'

  has_many :order_foods, dependent: :restrict_with_exception
  has_many :entity_tags, as: :entity, dependent: :destroy

  has_one_attached :image
end
