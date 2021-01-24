# frozen_string_literal: true

require 'test_helper'

class ContactsTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper

  test '#new' do
    get new_contact_path

    assert_select 'div.contact-us' do
      assert_select 'h3', I18n.t('app.contacts.new.title')
      assert_select 'p', CGI.unescapeHTML(strip_tags(I18n.t('app.contacts.new.description_html', phone_number: '+44 7668994563')))
      assert_select 'form' do
        assert_select 'label', 'Message'
        assert_select 'textarea[placeholder=?]', I18n.t('app.contacts.new.textarea_placeholder')
      end
    end
  end
end
