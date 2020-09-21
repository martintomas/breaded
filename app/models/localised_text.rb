# frozen_string_literal: true

class LocalisedText < ApplicationRecord
  has_many :text_translations, dependent: :destroy
  has_many :tag_names, class_name: 'Tag', foreign_key: 'name_id', dependent: :nullify
  has_many :food_names, class_name: 'Food', foreign_key: 'name_id', dependent: :nullify
  has_many :food_descriptions, class_name: 'Food', foreign_key: 'description_id', dependent: :nullify
  has_many :producer_names, class_name: 'Producer', foreign_key: 'name_id', dependent: :nullify
  has_many :producer_descriptions, class_name: 'Producer', foreign_key: 'description_id', dependent: :nullify
end
