# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :name, class_name: 'LocalisedText'
  belongs_to :tag_type

  has_one_attached :image
end
