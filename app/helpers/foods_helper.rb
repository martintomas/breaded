# frozen_string_literal: true

module FoodsHelper
  def last_word_split(value)
    text_fragments = value.split ' '
    return value if text_fragments.length == 1

    (text_fragments[0..-2].join(' ') + content_tag(:span, text_fragments.last, class: 'lastwordsplit')).html_safe
  end

  def print_attributes_of(tags)
    tags.map do |tag|
      case tag.code
      when 'vegan'
        content_tag(:span, content_tag(:i, 'V') + tag.localized_name, class: 'veganChoise')
      when 'gluten_free'
        content_tag(:span, content_tag(:i, 'G') + tag.localized_name, class: 'glutenChoise')
      else
        content_tag(:span, content_tag(:i, tag.localized_name[0].upcase) + tag.localized_name)
      end
    end.join(' ').html_safe
  end

  def truncate_long(text, max_length: 250, hard_length: 500)
    return text if text.length < max_length

    res = text[0..max_length - 1]
    (max_length..text.length).each do |i|
      res += text[i]
      return res if text[i] == '.' || i >= hard_length
    end
  end

  def print_tags_from(tags, tag_type:)
    tags.select { |tag| tag.tag_type_id == tag_type.id }.map(&:localized_name).join(', ')
  end
end
