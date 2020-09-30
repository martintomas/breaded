# frozen_string_literal: true

class EntityTag < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :tag

  validates_uniqueness_of :entity_id, scope: %i[tag_id entity_type]
end
