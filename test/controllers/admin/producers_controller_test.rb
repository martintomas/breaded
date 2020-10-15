# frozen_string_literal: true

require 'test_helper'

class Admin::ProducersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @producer = producers :bread_and_butter
  end

  test '#index' do
    get admin_producers_url

    assert_response :success
  end

  test '#show' do
    get admin_producer_url(@producer)

    assert_response :success
  end

  test '#new' do
    get new_admin_producer_url

    assert_response :success
  end

  test '#create' do
    assert_difference 'Producer.count', 1 do
      assert_difference 'LocalisedText.count', 2 do
        post admin_producers_url, params: { producer: { name_attributes: { text_translations_attributes:
                                                                             { "0"=>{ language_id: Language.the_en.id,
                                                                                      text: "test" }}},
                                                        description_attributes: { text_translations_attributes:
                                                                                    { "0"=>{ language_id: Language.the_en.id,
                                                                                             text: "test2" }}},
                                                        enabled: '1' }}
        producer = Producer.last
        assert_equal 'test', producer.localized_name
        assert_equal 'test2', producer.localized_description
        assert producer.enabled
        assert_redirected_to admin_producer_url(producer)
      end
    end
  end

  test '#update' do
    assert_no_difference 'LocalisedText.count' do
      patch admin_producer_url(@producer),
            params: { producer:
                        { name_attributes:
                            { text_translations_attributes:
                                { "0"=>{ language_id: Language.the_en.id,
                                         text: "test",
                                         id: text_translations(:bread_and_butter_name_translation).id }},
                              id: localised_texts(:bread_and_butter_name).id },
                          description_attributes:
                            { text_translations_attributes:
                                { "0"=>{ language_id: Language.the_en.id,
                                         text: "test2",
                                         id: text_translations(:bread_and_butter_description_translation).id }},
                              id: localised_texts(:bread_and_butter_description).id },
                          enabled: '0' } }

      @producer.reload
      assert_equal 'test', @producer.localized_name
      assert_equal 'test2', @producer.localized_description
      refute @producer.enabled
      assert_redirected_to admin_producer_url(@producer)
    end
  end

  test '#destroy' do
    assert_difference 'Producer.count', -1 do
      delete admin_producer_url(producers(:deletable_producer))

      assert_redirected_to admin_producers_url
    end
  end
end
