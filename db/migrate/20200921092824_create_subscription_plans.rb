class CreateSubscriptionPlans < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_plans do |t|
      t.decimal :price, precision: 11, scale: 4
      t.references :currency, null: false, foreign_key: true
      t.integer :number_of_deliveries

      t.timestamps
    end
  end
end
