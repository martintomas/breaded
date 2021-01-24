# frozen_string_literal: true

require "application_system_test_case"

class Admin::FaqsSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @faq = faqs :faq_1
  end

  test '#create' do
    visit new_admin_faq_url

    within 'form#new_faq' do
      fill_in 'faq[question_attributes][text_translations_attributes][0][text]', with: 'New Question'
      fill_in 'faq[answer_attributes][text_translations_attributes][0][text]', with: 'New Answer'
      click_on 'Create Faq'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'New Question'
            assert_selector 'td', text: 'New Answer'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_faq_url(@faq)

    within "form#edit_faq_#{@faq.id}" do
      fill_in 'faq[question_attributes][text_translations_attributes][0][text]', with: 'Test Question'
      fill_in 'faq[answer_attributes][text_translations_attributes][0][text]', with: 'Test Answer'
      click_on 'Update Faq'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'New Question'
            assert_selector 'td', text: 'New Answer'
          end
        end
      end
    end
  end
end
