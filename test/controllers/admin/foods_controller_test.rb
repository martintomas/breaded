# frozen_string_literal: true

require 'test_helper'

class Admin::FoodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @food = foods :rye_bread
  end

  test '#index' do
    get admin_foods_url

    assert_response :success
  end

  test '#show' do
    get admin_food_url(@food)

    assert_response :success
  end

  test '#new' do
    get new_admin_food_url

    assert_response :success
  end

  test '#edit' do
    get edit_admin_food_url(@food)

    assert_response :success
  end

  test '#create' do
    assert_difference 'Food.count', 1 do
      assert_difference 'LocalisedText.count', 2 do
        post admin_foods_url, params: { food: { name_attributes: { text_translations_attributes:
                                                                       { "0"=>{ language_id: Language.the_en.id,
                                                                                text: "test" }}},
                                                description_attributes: { text_translations_attributes:
                                                                              { "0"=>{ language_id: Language.the_en.id,
                                                                                       text: "test2" }}},
                                                producer_id: producers(:bread_and_butter).id,
                                                image_detail: fixture_file_upload('/files/product-1.png', 'image/png'),
                                                image_description: fixture_file_upload('/files/product-1.png', 'image/png'),
                                                tag_ids: tags(:vegetarian_tag, :honey_tag).map(&:id),
                                                enabled: '0' }}
        food = Food.last
        assert_equal 'test', food.localized_name
        assert_equal 'test2', food.localized_description
        assert_equal producers(:bread_and_butter), food.producer
        refute_nil food.image_detail
        refute_nil food.image_description
        refute food.enabled
        assert tags(:vegetarian_tag, :honey_tag).all? { |tag| tag.in? food.tags }
        assert_redirected_to admin_food_url(food)
      end
    end
  end

  test '#update' do
    assert_no_difference 'LocalisedText.count' do
      patch admin_food_url(@food),
            params: { food:
                          { name_attributes:
                                { text_translations_attributes:
                                      { "0"=>{ language_id: Language.the_en.id,
                                               text: "test",
                                               id: text_translations(:rye_bread_name_translation).id }},
                                  id: localised_texts(:rye_bread_name).id },
                            description_attributes:
                                { text_translations_attributes:
                                      { "0"=>{ language_id: Language.the_en.id,
                                               text: "test2",
                                               id: text_translations(:rye_bread_description_translation).id }},
                                  id: localised_texts(:rye_bread_description).id },
                            producer_id: producers(:deletable_producer).id,
                            image_detail: fixture_file_upload('/files/product-1.png', 'image/png'),
                            tag_ids: tags(:vegetarian_tag, :honey_tag).map(&:id),
                            enabled: '1' } }
      @food.reload
      assert_equal 'test', @food.localized_name
      assert_equal 'test2', @food.localized_description
      assert_equal producers(:deletable_producer), @food.producer
      refute_nil @food.image_detail
      assert @food.enabled
      assert tags(:vegetarian_tag, :honey_tag).all? { |tag| tag.in? @food.tags }
      assert_redirected_to admin_food_url(@food)
    end
  end

  test '#destroy' do
    assert_difference 'Food.count', -1 do
      delete admin_food_url(foods(:deletable_food))

      assert_redirected_to admin_foods_url
    end
  end
end
