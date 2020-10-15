class CreateOrderStateRelations < ActiveRecord::Migration[6.0]
  def change
    create_table :order_state_relations do |t|
      t.references :order_state, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
