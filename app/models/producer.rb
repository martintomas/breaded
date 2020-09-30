# frozen_string_literal: true

class Producer < ApplicationRecord
  belongs_to :name, class_name: 'LocalisedText'
  belongs_to :description, class_name: 'LocalisedText'
  belongs_to :producer_application, optional: true

  has_many :foods, dependent: :destroy
end
