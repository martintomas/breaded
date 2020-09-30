class CreateProducerApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :producer_applications do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone_number

      t.timestamps
    end
  end
end
