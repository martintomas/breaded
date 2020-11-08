# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  belongs_to :address_type, optional: true

  validates :street, :postal_code, :city, :state, presence: true
  validates :main, inclusion: { in: [true, false] }

  before_validation :prepare_default

  def to_s
    "#{address_line}, #{street} #{city}"
  end

  private

  def prepare_default
    self.state ||= 'UK'
  end
end
