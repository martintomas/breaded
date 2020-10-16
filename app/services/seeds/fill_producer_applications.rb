# frozen_string_literal: true

class Seeds::FillProducerApplications
  def self.perform_for(producer_applications)
    producer_applications.each do |producer_application|
      next if ProducerApplication.where(email: producer_application[:email]).exists?

      puts "producer application: #{producer_application[:email]}"
      tag_ids = find_tags_for producer_application.delete(:tags)
      ProducerApplication.create! producer_application.merge(tag_ids: tag_ids)
    end
  end

  def self.find_tags_for(values)
    values.map do |tag|
      Tag.joins(name: :text_translations).find_by!(text_translations: { text: tag[:name] },
                                                   tag_type: tag[:tag_type]).id
    end
  end
end
