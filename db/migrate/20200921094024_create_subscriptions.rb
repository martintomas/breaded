class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :subscription_plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :number_of_items
      t.boolean :active, default: true
      t.string :stripe_subscription

      t.timestamps
    end
  end
end
