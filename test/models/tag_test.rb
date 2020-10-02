# frozen_string_literal: true

require 'test_helper'

class TagTest < ActiveSupport::TestCase
  setup do
    @tag = tags(:vegetarian_tag)
    @full_content = { name: localised_texts(:vegetarian_localized_text),
                      tag_type: tag_types(:attribute) }
  end

  test 'the validity - empty is not valid' do
    model = Tag.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Tag.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without name is not valid' do
    invalid_with_missing Tag, :name
  end

  test 'the validity - without tag_type is not valid' do
    invalid_with_missing Tag, :tag_type
  end

  test '#localized_name - when translation exists' do
    I18n.with_locale :en do
      assert_equal text_translations(:vegetarian_translation).text, @tag.localized_name
    end
  end

  test '#localized_name - when translation is missing' do
    I18n.with_locale :en do
      text_translations(:vegetarian_translation).delete
      assert_nil @tag.localized_name
    end
  end
end
