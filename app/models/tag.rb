# frozen_string_literal: true

class Tag < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name

  belongs_to :tag_type

  has_many :entity_tags, dependent: :destroy

  validates_uniqueness_of :code, scope: :tag_type_id, if: -> (tag) { tag.code.present? }

  scope :categories, -> { where(tag_type: TagType.the_category) }
  scope :ingredients, -> { where(tag_type: TagType.the_ingredient) }
  scope :attributes, -> { where(tag_type: TagType.the_attribute) }
  scope :goes_well, -> { where(tag_type: TagType.the_goes_well) }
  scope :others, -> { where(tag_type: TagType.the_other) }

  def to_s
    localized_name
  end
end
