class CreateAddressTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :address_types do |t|
      t.string :code
      t.index :code, unique: true

      t.timestamps
    end
  end
end
