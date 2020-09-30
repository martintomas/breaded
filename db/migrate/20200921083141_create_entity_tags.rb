class CreateEntityTags < ActiveRecord::Migration[6.0]
  def change
    create_table :entity_tags do |t|
      t.references :entity,polymorphic: true, index: { name: 'index_entity_tags_on_entity' }
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
    add_index :entity_tags, [:entity_id, :entity_type, :tag_id], unique: true
  end
end
