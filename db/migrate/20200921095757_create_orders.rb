class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :delivery_date
      t.boolean :delivered, default: false
      t.boolean :finalised, default: false

      t.timestamps
    end
  end
end
