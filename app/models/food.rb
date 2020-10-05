# frozen_string_literal: true

class Food < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name, :description

  belongs_to :producer

  has_many :order_foods, dependent: :restrict_with_exception
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags

  has_one_attached :image

  accepts_nested_attributes_for :entity_tags

  def to_s
    localized_name
  end
end
