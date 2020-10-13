# frozen_string_literal: true

require 'test_helper'

class FoodsHelperTest < ActionView::TestCase
  test '.last_word_split - single word' do
    word = 'test'
    assert_equal word, last_word_split(word)
  end

  test '.last_word_split - multiple word' do
    word = 'test test2 test3'
    assert_equal 'test test2 '+ content_tag(:span, 'test3', class: 'lastwordsplit'),
                 last_word_split(word)
  end

  test '.print_attributes_of - specific tag' do
    tag = tags(:vegetarian_tag)
    assert_equal content_tag(:span, content_tag(:i, 'V') + tag.localized_name, class: 'veganChoise'),
                 print_attributes_of(tag)
  end

  test '.print_attributes_of - common tag' do
    tag = tags(:butter_tag)
    assert_equal content_tag(:span, content_tag(:i, tag.localized_name[0].upcase) + tag.localized_name),
                 print_attributes_of(tag)
  end

  test '.print_attributes_of - multiple tags' do
    tag1 = tags(:vegetarian_tag)
    tag2 = tags(:butter_tag)

    content1 = content_tag(:span, content_tag(:i, 'V') + tag1.localized_name, class: 'veganChoise')
    content2 = content_tag(:span, content_tag(:i, tag2.localized_name[0].upcase) + tag2.localized_name)
    assert_equal content1 + ' ' + content2, print_attributes_of([tag1, tag2])
  end

  test '.truncate_long_description_of -- short string' do
    I18n.with_locale :en do
      producer = producers(:bread_and_butter)
      assert_equal text_translations(:bread_and_butter_description_translation).text, truncate_long_description_of(producer)
    end
  end

  test '.truncate_long -- string over max length' do
    I18n.with_locale :en do
      producer = producers(:bread_and_butter)
      text = text_translations(:bread_and_butter_description_translation).text
      assert_equal text[0..6] + '...' + link_to(I18n.t('app.browse_bread.read_more'), '#'),
                   truncate_long_description_of(producer, max_length: 10)
    end
  end

  test '.print_tags_from' do
    tag1 = tags(:vegetarian_tag)
    tag2 = tags(:butter_tag)
    assert_equal tag1.localized_name, print_tags_from([tag1, tag2], tag_type: tag1.tag_type)
  end
end
