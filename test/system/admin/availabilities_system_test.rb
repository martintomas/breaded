# frozen_string_literal: true

require "application_system_test_case"

class Admin::AvailabilitiesSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @availability = availabilities :availability_monday
  end

  test '#create' do
    visit new_admin_availability_url

    within 'form#new_availability' do
      fill_in 'availability[day_in_week]', with: '5'
      select '10', from: 'availability[time_from(4i)]'
      select '00', from: 'availability[time_from(5i)]'
      select '14', from: 'availability[time_to(4i)]'
      select '00', from: 'availability[time_to(5i)]'
      click_on 'Create Availability'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: '5'
            assert_selector 'td', text: '10:00'
            assert_selector 'td', text: '14:00'
          end
        end
      end
    end
  end

  test '#update' do
    visit edit_admin_availability_url(@availability)

    within "form#edit_availability" do
      fill_in 'availability[day_in_week]', with: '5'
      click_on 'Update Availability'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel_contents' do
          within 'table' do
            assert_selector 'td', text: '5'
          end
        end
      end
    end
  end
end
