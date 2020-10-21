# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :address_type

  validates :street, :postal_code, :city, :state, presence: true
  validates :main, inclusion: { in: [true, false] }
end
