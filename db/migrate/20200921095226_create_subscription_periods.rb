class CreateSubscriptionPeriods < ActiveRecord::Migration[6.0]
  def change
    create_table :subscription_periods do |t|
      t.references :subscription, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end
end
