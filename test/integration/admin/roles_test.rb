# frozen_string_literal: true

require 'test_helper'

class Admin::RolesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @role = roles :admin
  end

  test 'is shown at menu' do
    get admin_roles_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.user')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.roles.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_roles_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.roles.label')
    end
  end

  test '#index' do
    get admin_roles_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_roles' do
            Role.all.each do |role|
              assert_select 'tr' do
                assert_select 'td', role.name
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_role_url(@role)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @role.name
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @role.name
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_role_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Role'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_role' do
          assert_select 'input[name="role[name]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_role_url(@role)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Role'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#edit_role' do
          assert_select 'input[name="role[name]"][value=?]', @role.name
        end
      end
    end
  end
end
