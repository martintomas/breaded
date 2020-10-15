# frozen_string_literal: true

require 'test_helper'

class Admin::TagsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @tag = tags :vegetarian_tag
  end

  test '#index' do
    get admin_tags_url

    assert_response :success
  end

  test '#show' do
    get admin_tag_url(@tag)

    assert_response :success
  end

  test '#new' do
    get new_admin_tag_url

    assert_response :success
  end

  test '#create' do
    assert_difference 'Tag.count', 1 do
      assert_difference 'LocalisedText.count', 1 do
        post admin_tags_url, params: { tag: { name_attributes: { text_translations_attributes:
                                                                     { "0"=>{ language_id: Language.the_en.id,
                                                                              text: "test" }}},
                                              tag_type_id: tag_types(:ingredient).id }}
        tag = Tag.last
        assert_equal 'test', tag.localized_name
        assert_equal tag_types(:ingredient), tag.tag_type
        assert_redirected_to admin_tag_url(tag)
      end
    end
  end

  test '#update' do
    assert_no_difference 'LocalisedText.count' do
      patch admin_tag_url(@tag),
            params: { tag:
                          { name_attributes:
                                { text_translations_attributes:
                                      { "0"=>{ language_id: Language.the_en.id,
                                               text: "test",
                                               id: text_translations(:vegetarian_translation).id }},
                                  id: localised_texts(:vegetarian_localized_text).id },
                            tag_type_id: tag_types(:ingredient).id } }

      @tag.reload
      assert_equal 'test', @tag.localized_name
      assert_equal tag_types(:ingredient), @tag.tag_type
      assert_redirected_to admin_tag_url(@tag)
    end
  end

  test '#destroy' do
    assert_difference 'Tag.count', -1 do
      delete admin_tag_url(@tag)

      assert_redirected_to admin_tags_url
    end
  end
end
