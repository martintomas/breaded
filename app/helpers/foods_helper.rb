# frozen_string_literal: true

module FoodsHelper
  def last_word_split(value)
    text_fragments = value.split ' '
    return value if text_fragments.length == 1

    (text_fragments[0..-2].join(' ') + ' ' + content_tag(:span, text_fragments.last, class: 'lastwordsplit')).html_safe
  end

  def print_attributes_of(tags)
    Array.wrap(tags).map do |tag|
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

  def truncate_long_description_of(producer, max_length: 150)
    description = producer.localized_description
    output = truncate(description, length: max_length, omission: '...')
    output += link_to I18n.t('app.browse_bread.read_more'), '#' if description.size > max_length
    output.html_safe
  end

  def print_tags_from(tags, tag_type:)
    tags.select { |tag| tag.tag_type_id == tag_type.id }.map(&:localized_name).join(', ')
  end
end
