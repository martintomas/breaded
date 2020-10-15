class CreateOrderStates < ActiveRecord::Migration[6.0]
  def change
    create_table :order_states do |t|
      t.string :code
      t.index :code, unique: true

      t.timestamps
    end
  end
end
