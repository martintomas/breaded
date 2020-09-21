class CreateTags < ActiveRecord::Migration[6.0]
  def change
    create_table :tags do |t|
      t.references :name, null: false, foreign_key: { to_table: :localised_texts }
      t.references :tag_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
