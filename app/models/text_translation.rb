# frozen_string_literal: true

class TextTranslation < ApplicationRecord
  belongs_to :language
  belongs_to :localised_text

  validates :text, presence: true
  validates_uniqueness_of :localised_text_id, scope: :language_id
end
