class CreateAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :addresses do |t|
      t.references :addressable,polymorphic: true, index: { name: 'index_addresses_on_addressable' }
      t.string :address_line
      t.string :street
      t.string :postal_code
      t.string :city
      t.string :state

      t.timestamps
    end
  end
end
