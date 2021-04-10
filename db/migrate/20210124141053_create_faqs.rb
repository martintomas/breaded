class CreateFaqs < ActiveRecord::Migration[6.0]
  def change
    create_table :faqs do |t|
      t.references :question, null: false, foreign_key: { to_table: :localised_texts }
      t.references :answer, null: false, foreign_key: { to_table: :localised_texts }

      t.timestamps
    end
  end
end
