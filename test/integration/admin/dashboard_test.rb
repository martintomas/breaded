# frozen_string_literal: true

require 'test_helper'

class Admin::DashboardTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    get admin_dashboard_url
    assert_response :success
  end

  test 'is shown at menu' do
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t("active_admin.dashboard")
      end
    end
  end

  test 'shows proper title' do
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t("active_admin.dashboard")
    end
  end

  test 'shows proper content' do
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel:nth-of-type(1)' do
          assert_select 'h3', I18n.t('active_admin.dashboards.panels.recent_applications')
          assert_select 'table' do
            assert_select 'tr' do
              ProducerApplication.order(:created_at).first(5).each do |producer_application|
                assert_select 'td', producer_application.first_name
                assert_select 'td', producer_application.last_name
                assert_select 'td', producer_application.email
                assert_select 'td', producer_application.phone_number
                assert_select 'td', I18n.t('active_admin.dashboards.see_detail')
              end
            end
          end
        end
      end
    end
  end
end
