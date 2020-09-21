class CreateTextTranslations < ActiveRecord::Migration[6.0]
  def change
    create_table :text_translations do |t|
      t.text :text
      t.references :language, null: false, foreign_key: true
      t.references :localised_text, null: false, foreign_key: true

      t.timestamps
    end
    add_index :text_translations, [:language_id, :localised_text_id], unique: true
  end
end
