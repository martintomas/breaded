# frozen_string_literal: true

require "application_system_test_case"

class Admin::TagTypesSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @tag_type = tag_types :ingredient
  end

  test '#create' do
    visit new_admin_tag_type_url

    within 'form#new_tag_type' do
      fill_in 'tag_type[code]', with: 'Custom Tag Type'
      click_on 'Create Tag type'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Custom Tag Type'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_tag_type_url(@tag_type)

    within "form#edit_tag_type" do
      fill_in 'tag_type[code]', with: 'Updated Tag Type'
      click_on 'Update Tag type'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Updated Tag Type'
          end
        end
      end
    end
  end
end
