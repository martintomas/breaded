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
        assert_select 'span', I18n.t("active_admin.dashboard_welcome.welcome")
        assert_select 'small', I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
  end
end
