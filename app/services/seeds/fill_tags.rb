# frozen_string_literal: true

class Seeds::FillTags
  def self.perform_for(tags, tag_type:)
    tags.each do |tag|
      next if Tag.joins(name: :text_translations).where(text_translations: { text: tag }, tag_type: tag_type).exists?

      puts "tag: #{tag}"
      Tag.create! tag_type: tag_type,
                  code: tag.parameterize.underscore,
                  name_attributes: { text_translations_attributes: [{ text: tag, language: Language.the_en }] }
    end
  end
end
