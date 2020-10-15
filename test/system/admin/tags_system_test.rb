# frozen_string_literal: true

require "application_system_test_case"

class Admin::TagsSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @tag = tags :vegetarian_tag
  end

  test '#create' do
    visit new_admin_tag_url

    within 'form#new_tag' do
      fill_in 'tag[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      select TagType.first.to_s, from: 'tag[tag_type_id]'
      click_on 'Create Tag'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: TagType.first.to_s
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_tag_url(@tag)

    within "form#edit_tag_#{@tag.id}" do
      fill_in 'tag[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      select TagType.first.to_s, from: 'tag[tag_type_id]'
      click_on 'Update Tag'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: TagType.first.to_s
          end
        end
      end
    end
  end
end
