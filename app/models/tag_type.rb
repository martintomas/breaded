# frozen_string_literal: true

class TagType < BaseType
  has_many :tags, dependent: :destroy
end
