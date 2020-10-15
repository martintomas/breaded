# frozen_string_literal: true

class Food < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name, :description

  belongs_to :producer

  has_many :order_foods, dependent: :restrict_with_exception
  has_many :entity_tags, as: :entity, dependent: :destroy
  has_many :tags, through: :entity_tags

  has_one_attached :image_detail
  has_one_attached :image_description

  accepts_nested_attributes_for :entity_tags

  validates :enabled, inclusion: { in: [true, false] }
  validates :image_detail, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']
  validates :image_description, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']

  scope :enabled, -> { where(enabled: true) }

  def to_s
    localized_name
  end
end
