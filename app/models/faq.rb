# frozen_string_literal: true

class Faq < ApplicationRecord
  include TranslatedFields

  add_translated_fields :question, :answer

  def to_s
    localized_question
  end
end
