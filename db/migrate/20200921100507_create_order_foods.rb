class CreateOrderFoods < ActiveRecord::Migration[6.0]
  def change
    create_table :order_foods do |t|
      t.references :food, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :amount
      t.boolean :automatic, default: false

      t.timestamps
    end
    add_index :order_foods, [:food_id, :order_id], unique: true
  end
end
