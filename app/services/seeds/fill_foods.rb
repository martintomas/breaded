# frozen_string_literal: true

class Seeds::FillFoods
  def self.perform_for(foods)
    foods.each do |food|
      next if Food.joins(name: :text_translations).where(text_translations: { text: food[:name] }).exists?

      puts "food: #{food[:name]}"
      ActiveRecord::Base.transaction do
        food_obj = Food.create! name_attributes: { text_translations_attributes: [{ text: food[:name], language: Language.the_en }] },
                                description_attributes: { text_translations_attributes: [{ text: food[:description], language: Language.the_en }] },
                                entity_tags_attributes: collect_all(food[:tags]).map { |tag_id| { tag_id: tag_id }},
                                producer: producer_with(food[:producer])
        food_obj.image.attach(io: File.open(Rails.root.join('app/services/seeds/images', food[:image])), filename: food[:image])
      end
    end
  end

  def self.collect_all(tags)
    tags.map do |tag|
      Tag.joins(name: :text_translations).find_by!(text_translations: { text: tag[:name] }, tag_type: tag[:tag_type]).id
    end
  end

  def self.producer_with(name)
    Producer.joins(name: :text_translations).find_by! text_translations: { text: name }
  end
end
