class CreateOrderSurprises < ActiveRecord::Migration[6.0]
  def change
    create_table :order_surprises do |t|
      t.references :order, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
