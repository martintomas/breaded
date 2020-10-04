# frozen_string_literal: true

class Tag < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name

  belongs_to :tag_type

  has_one_attached :image

  scope :categories, -> { where(tag_type: TagType.the_category) }
end
