# frozen_string_literal: true

require "application_system_test_case"

class Admin::ProducersSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @producer = producers :bread_and_butter
  end

  test '#create' do
    visit new_admin_producer_url

    within 'form#new_producer' do
      fill_in 'producer[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      fill_in 'producer[description_attributes][text_translations_attributes][0][text]', with: 'Test Description'
      click_on 'Create Producer'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: 'Test Description'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_producer_url(@producer)

    within "form#edit_producer_#{@producer.id}" do
      fill_in 'producer[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      fill_in 'producer[description_attributes][text_translations_attributes][0][text]', with: 'Test Description'
      click_on 'Update Producer'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: 'Test Description'
          end
        end
      end
    end
  end
end
