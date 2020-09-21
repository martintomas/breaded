class CreateLocalisedTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :localised_texts do |t|

      t.timestamps
    end
  end
end
