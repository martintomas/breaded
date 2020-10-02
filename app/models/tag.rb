# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :name, class_name: 'LocalisedText'
  belongs_to :tag_type

  has_one_attached :image

  accepts_nested_attributes_for :name

  scope :categories, -> { where(tag_type: TagType.the_category) }
  scope :with_translations, -> { includes(name: { text_translations: :language })}

  def localized_name
    name.text_translations.detect { |t| t.language.code.to_sym == I18n.locale }&.text
  end
end
