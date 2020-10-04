# frozen_string_literal: true

class Producer < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name, :description

  belongs_to :producer_application, optional: true

  has_many :foods, dependent: :destroy
end
