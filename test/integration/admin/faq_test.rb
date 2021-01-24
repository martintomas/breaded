# frozen_string_literal: true

require 'test_helper'

class Admin::FaqsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @faq = faqs :faq_1
  end

  test 'is shown at menu' do
    get admin_faqs_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.tag')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.faqs.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_faqs_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.faqs.label')
    end
  end

  test '#index' do
    get admin_faqs_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_faqs' do
            Faq.all.each do |faq|
              assert_select 'tr' do
                assert_select 'td', faq.localized_question
                assert_select 'td', faq.localized_answer
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_faq_url(@faq)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @faq.localized_question
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @faq.localized_question
            assert_select 'td', @faq.localized_answer
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_faq_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Faq'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_faq' do
          assert_select 'textarea[name="faq[question_attributes][text_translations_attributes][0][text]"]'
          assert_select 'textarea[name="faq[answer_attributes][text_translations_attributes][0][text]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_faq_url(@faq)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Faq'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_faq_#{@faq.id}" do
          assert_select 'textarea[name="faq[question_attributes][text_translations_attributes][0][text]"]',
                        @faq.localized_question
          assert_select 'textarea[name="faq[answer_attributes][text_translations_attributes][0][text]"]',
                        @faq.localized_answer
        end
      end
    end
  end
end
