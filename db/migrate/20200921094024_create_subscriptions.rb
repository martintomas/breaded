class CreateSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :subscriptions do |t|
      t.references :subscription_plan, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :surprise_me_count, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
