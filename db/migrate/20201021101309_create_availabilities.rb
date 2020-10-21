class CreateAvailabilities < ActiveRecord::Migration[6.0]
  def change
    create_table :availabilities do |t|
      t.integer :day_in_week
      t.time :time_from
      t.time :time_to

      t.timestamps
    end
  end
end
