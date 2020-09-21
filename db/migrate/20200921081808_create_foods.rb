class CreateFoods < ActiveRecord::Migration[6.0]
  def change
    create_table :foods do |t|
      t.references :name, null: false, foreign_key: { to_table: :localised_texts }
      t.references :description, null: false, foreign_key: { to_table: :localised_texts }
      t.references :producer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
