# frozen_string_literal: true

class OrderSurprise < ApplicationRecord
  belongs_to :order

  has_one :entity_tag, as: :entity, dependent: :destroy
  has_one :tag, through: :entity_tag

  validates_presence_of :tag
end
