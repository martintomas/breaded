# frozen_string_literal: true

require 'test_helper'

class TranslatedFieldsTest < ActiveSupport::TestCase
  setup do
    @model = Producer.first
  end

  test '#localized_name - when translation exists' do
    I18n.with_locale :en do
      assert_equal text_translations(:bread_and_butter_name_translation).text, @model.localized_name
    end
  end

  test '#localized_description - when translation exists' do
    I18n.with_locale :en do
      assert_equal text_translations(:bread_and_butter_description_translation).text, @model.localized_description
    end
  end

  test '#localized_name - when translation is missing' do
    I18n.with_locale :en do
      text_translations(:bread_and_butter_name_translation).delete
      assert_nil @model.localized_name
    end
  end
end
