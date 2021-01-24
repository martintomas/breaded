# frozen_string_literal: true

require "application_system_test_case"

class AddressesSystemTest < ApplicationSystemTestCase
  test '#create' do
    visit new_contact_path
    within 'form' do
      fill_in 'contacts[message]', with: 'Can somebody help me?'
      click_button I18n.t('app.contacts.new.button')
    end

    assert_selector 'div.flash', text: I18n.t('app.contacts.new.notification')
  end
end
