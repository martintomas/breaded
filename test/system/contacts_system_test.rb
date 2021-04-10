# frozen_string_literal: true

require "application_system_test_case"

class ContactsSystemTest < ApplicationSystemTestCase
  setup do
    @user = users :customer
  end

  test '#create' do
    visit new_contact_path
    within 'form' do
      fill_in 'contacts[message]', with: 'Can somebody help me?'
      click_button I18n.t('app.contacts.new.button')
    end

    assert_selector 'div.flash', text: I18n.t('app.contacts.new.notification')
  end

  test '#send_support_message' do
    login_as_customer
    visit support_contacts_path

    within 'form' do
      fill_in 'contacts[message]', with: 'Can somebody help me?'
      select_dropdown_with subscription_periods(:customer_1_subscription_1_period).started_at.strftime('%b')
      select_dropdown_with I18n.t('app.contacts.support.issue_box.box', i: 1), type: :box
      click_button I18n.t('app.contacts.support.button')
    end

    assert_selector 'div.flash', text: I18n.t('app.contacts.support.notification')
  end

  private

  def select_dropdown_with(value, type: :month)
    find(".drop-down.#{type} .selected a").click
    within ".options.#{type}-option ul" do
      find('li', text: value.to_s).click
    end
  end
end
