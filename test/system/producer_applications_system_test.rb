# frozen_string_literal: true

require "application_system_test_case"

class ProducerApplicationsSystemTest < ApplicationSystemTestCase
  test '#create' do
    visit new_producer_application_path

    within 'form.bakersignup-form' do
      fill_in 'producer_application[first_name]', with: 'First Name'
      fill_in 'producer_application[last_name]', with: 'Last Name'
      fill_in 'producer_application[email]', with: 'test@test.test'
      fill_in 'producer_application[phone_number]', with: '12345678'
      click_on 'Submit'
    end
    assert_selector 'div.flash', text: I18n.t('app.baker_signup.notice')
  end
end
