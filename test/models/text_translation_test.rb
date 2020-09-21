# frozen_string_literal: true

require 'test_helper'

class TextTranslationTest < ActiveSupport::TestCase
  setup do
    @full_content = { text: 'This is translated text',
                      language: languages(:cs),
                      localised_text: localised_texts(:translated_text_1) }
  end

  test 'the validity - empty is not valid' do
    model = TextTranslation.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = TextTranslation.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without text is not valid' do
    invalid_with_missing TextTranslation, :text
  end

  test 'the validity - without language is not valid' do
    invalid_with_missing TextTranslation, :language
  end

  test 'the validity - without localised_text is not valid' do
    invalid_with_missing TextTranslation, :localised_text
  end

  test 'the validity - combination of language and localised_text has to be unique' do
    TextTranslation.create! @full_content
    refute TextTranslation.new(@full_content).valid?
  end
end
