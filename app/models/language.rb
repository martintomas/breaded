# frozen_string_literal: true

class Language < BaseType
  has_many :text_translations, dependent: :destroy
end
