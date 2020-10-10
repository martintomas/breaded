# frozen_string_literal: true

class Seeds::FillFoods
  def self.perform_for(foods)
    foods.each do |food|
      next if Food.joins(name: :text_translations).where(text_translations: { text: food[:name] }).exists?

      puts "food: #{food[:name]}"
      food_obj = Food.new name_attributes: { text_translations_attributes: [{ text: food[:name], language: Language.the_en }] },
                              description_attributes: { text_translations_attributes: [{ text: food[:description], language: Language.the_en }] },
                              entity_tags_attributes: collect_all(food[:tags]).map { |tag_id| { tag_id: tag_id }},
                              producer: producer_with(food[:producer])

      image_detail = File.open(Rails.root.join('app/services/seeds/images', food[:image_detail]))
      image_description = File.open(Rails.root.join('app/services/seeds/images', food[:image_description]))
      food_obj.image_detail.attach(io: image_detail, filename: food[:image_detail], content_type: 'image/png', identify: false)
      food_obj.image_description.attach(io: image_description, filename: food[:image_description], content_type: 'image/png', identify: false)
      food_obj.save!
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
