class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :subscription_period, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :delivery_date_from
      t.datetime :delivery_date_to

      t.timestamps
    end
  end
end
