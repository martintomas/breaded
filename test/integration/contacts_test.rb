# frozen_string_literal: true

require 'test_helper'

class ContactsTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
  end

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

  test '#support - main form' do
    sign_in @user
    get support_contacts_path

    assert_select 'div.support-section' do
      assert_select 'h3', I18n.t('app.contacts.support.title')
      assert_select 'p', CGI.unescapeHTML(strip_tags(I18n.t('app.contacts.support.description_html', phone_number: '+44 7668994563')))
      assert_select 'form' do
        assert_select 'label', 'Message'
        assert_select 'textarea[placeholder=?]', I18n.t('app.contacts.support.textarea_placeholder')
        assert_select 'span.issue-box', I18n.t('app.contacts.support.issue_box.title')
      end
    end
  end

  test '#support - month dropdown' do
    sign_in @user
    get support_contacts_path

    assert_select 'div.support-section' do
      assert_select 'div.drop-down.month' do
        assert_select 'div.selected.selected-month span', I18n.t('app.contacts.support.issue_box.select_month')
        assert_select 'div.options.month-option' do
          @user.subscription_periods.each do |subscription_period|
            assert_select 'li', subscription_period.started_at.strftime('%b')
          end
        end
      end
    end
  end

  test '#support - box dropdown' do
    sign_in @user
    get support_contacts_path

    assert_select 'div.support-section' do
      assert_select 'div.drop-down.box' do
        assert_select 'div.selected.selected-box span', I18n.t('app.contacts.support.issue_box.select_box')
        assert_select 'div.options.box-option' do
          4.times do |i|
            assert_select 'li', I18n.t('app.contacts.support.issue_box.box', i: i + 1)
          end
        end
      end
    end
  end
end
