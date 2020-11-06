# frozen_string_literal: true

module TranslatedFields
  extend ActiveSupport::Concern

  class_methods do
    def add_translated_fields(*attributes)
      attributes.each { |attribute| activate_translated_relation_for attribute }
      scope :with_translations, -> do
        preload(attributes.each_with_object({}) { |attribute, res| res[attribute] = { text_translations: :language } })
      end
    end

    def activate_translated_relation_for(attribute)
      belongs_to attribute, class_name: 'LocalisedText'
      accepts_nested_attributes_for attribute
      define_method "localized_#{attribute}" do
        send(attribute).text_translations.detect { |t| t.language.code.to_sym == I18n.locale }&.text
      end
    end
  end
end
