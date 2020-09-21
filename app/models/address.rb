# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :address_line, :street, :postal_code, :city, :state, presence: true
end
