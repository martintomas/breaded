class CreateProducers < ActiveRecord::Migration[6.0]
  def change
    create_table :producers do |t|
      t.references :name, null: false, foreign_key: { to_table: :localised_texts }
      t.references :description, null: false, foreign_key: { to_table: :localised_texts }
      t.references :producer_application, null: true, foreign_key: true
      t.boolean :enabled, default: true

      t.timestamps
    end
  end
end
