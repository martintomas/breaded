# frozen_string_literal: true

class Seeds::FillProducers
  def self.perform_for(producers)
    producers.each do |producer|
      next if Producer.joins(name: :text_translations).where(text_translations: { text: producer[:name] }).exists?

      puts "producer: #{producer[:name]}"
      Producer.create! name_attributes: { text_translations_attributes: [{ text: producer[:name], language: Language.the_en }] },
                       description_attributes: { text_translations_attributes: [{ text: producer[:description], language: Language.the_en }] }
    end
  end
end
