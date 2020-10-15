class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :delivery_date

      t.timestamps
    end
  end
end
