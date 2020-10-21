class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.references :subscription_period, null: false, foreign_key: true
      t.references :currency, null: false, foreign_key: true
      t.decimal :price, precision: 11, scale: 4

      t.timestamps
    end
  end
end
