class CreateSubscriptionSurprises < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_surprises do |t|
      t.references :subscription, null: false, foreign_key: true
      t.integer :amount

      t.timestamps
    end
  end
end
