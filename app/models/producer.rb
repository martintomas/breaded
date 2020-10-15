# frozen_string_literal: true

class Producer < ApplicationRecord
  include TranslatedFields

  add_translated_fields :name, :description

  belongs_to :producer_application, optional: true

  has_many :foods, dependent: :destroy

  validates :enabled, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }

  def to_s
    localized_name
  end
end
