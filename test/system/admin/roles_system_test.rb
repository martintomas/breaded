# frozen_string_literal: true

require "application_system_test_case"

class Admin::RolesSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @role = roles :customer
  end

  test '#create' do
    visit new_admin_role_url

    within 'form#new_role' do
      fill_in 'role[name]', with: 'Custom Role'
      click_on 'Create Role'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Custom Role'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_role_url(@role)

    within "form#edit_role_#{@role.id}" do
      fill_in 'role[name]', with: 'Updated Role'
      click_on 'Update Role'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: 'Updated Role'
          end
        end
      end
    end
  end
end
