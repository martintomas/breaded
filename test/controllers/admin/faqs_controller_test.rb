# frozen_string_literal: true

require 'test_helper'

class Admin::FaqsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @faq = faqs :faq_1
  end

  test '#index' do
    get admin_faqs_url

    assert_response :success
  end

  test '#show' do
    get admin_faq_url(@faq)

    assert_response :success
  end

  test '#new' do
    get new_admin_faq_url

    assert_response :success
  end

  test '#create' do
    assert_difference 'Faq.count', 1 do
      assert_difference 'LocalisedText.count', 2 do
        post admin_faqs_url, params: { faq: { question_attributes: { text_translations_attributes:
                                                                   { "0"=>{ language_id: Language.the_en.id,
                                                                            text: "test" }}},
                                              answer_attributes: { text_translations_attributes:
                                                                 { "0"=>{ language_id: Language.the_en.id,
                                                                          text: "test" }}}}}
        faq = Faq.last
        assert_equal 'test', faq.localized_question
        assert_equal 'test', faq.localized_answer
        assert_redirected_to admin_faq_url(faq)
      end
    end
  end

  test '#edit' do
    get edit_admin_faq_url(@faq)

    assert_response :success
  end

  test '#update' do
    assert_no_difference 'LocalisedText.count' do
      patch admin_faq_url(@faq),
            params: { faq:
                        { answer_attributes:
                            { text_translations_attributes:
                                { "0"=>{ language_id: Language.the_en.id,
                                         text: "test",
                                         id: text_translations(:how_many_breads_answer_translation).id }},
                              id: localised_texts(:how_many_breads_answer).id } } }

      @faq.reload
      assert_equal 'test', @faq.localized_answer
      assert_redirected_to admin_faq_url(@faq)
    end
  end

  test '#destroy' do
    assert_difference 'Faq.count', -1 do
      delete admin_faq_url(@faq)

      assert_redirected_to admin_faqs_url
    end
  end
end
