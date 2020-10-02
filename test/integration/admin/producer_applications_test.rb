# frozen_string_literal: true

require 'test_helper'

class Admin::ProducerApplicationsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @producer_application = producer_applications :producer_application_bread_and_butter
  end

  test 'is shown at menu' do
    get admin_producer_applications_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.producer')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.producer_applications.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_producer_applications_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.producer_applications.label')
    end
  end

  test '#index' do
    get admin_producer_applications_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_producer_applications' do
            ProducerApplication.all.each do |producer_application|
              assert_select 'tr' do
                assert_select 'td', producer_application.first_name
                assert_select 'td', producer_application.last_name
                assert_select 'td', producer_application.email
                assert_select 'td', producer_application.phone_number
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_producer_application_url(@producer_application)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @producer_application.email
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @producer_application.first_name
            assert_select 'td', @producer_application.last_name
            assert_select 'td', @producer_application.email
            assert_select 'td', @producer_application.phone_number
          end
        end
        assert_select 'div.panel#tags' do
          assert_select 'table' do
            assert_select 'tr' do
              @producer_application.tags.with_translations.each do |tag|
                assert_select 'td', tag.localized_name
              end
            end
          end
        end
      end
    end
  end
end
