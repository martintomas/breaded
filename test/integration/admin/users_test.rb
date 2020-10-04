# frozen_string_literal: true

require 'test_helper'

class Admin::UsersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @user = users :admin
  end

  test 'is shown at menu' do
    get admin_users_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.user')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.users.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_users_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.users.label')
    end
  end

  test '#index' do
    get admin_users_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_users' do
            User.all.each do |user|
              assert_select 'tr' do
                assert_select 'td', user.first_name
                assert_select 'td', user.last_name
                assert_select 'td', user.email
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_user_url(@user)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @user.email
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @user.first_name
            assert_select 'td', @user.last_name
            assert_select 'td', @user.email
            assert_select 'td', @user.reset_password_token
            assert_select 'td', @user.reset_password_sent_at&.strftime('%B %d, %Y %H:%M')
            assert_select 'td', @user.confirmed_at&.strftime('%B %d, %Y %H:%M')
            assert_select 'td', @user.confirmation_token
            assert_select 'td', @user.confirmation_sent_at&.strftime('%B %d, %Y %H:%M')
            assert_select 'td', @user.unconfirmed_email
          end
        end
        assert_select 'div.panel#roles' do
          assert_select 'table' do
            assert_select 'tr' do
              @user.roles.each do |role|
                assert_select 'td', role.name
              end
            end
          end
        end
        assert_select 'div.panel#address' do
          assert_select 'table' do
            assert_select 'td', @user.address.address_line
            assert_select 'td', @user.address.street
            assert_select 'td', @user.address.postal_code.to_s
            assert_select 'td', @user.address.city
            assert_select 'td', @user.address.state
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_user_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New User'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_user' do
          assert_select 'input[name="user[first_name]"]'
          assert_select 'input[name="user[last_name]"]'
          assert_select 'input[name="user[email]"]'
          assert_select 'input[name="user[password]"]'
          assert_select 'li#user_reset_password_sent_at_input'
          assert_select 'li#user_confirmed_at_input'
          assert_select 'select[name="user[role_ids][]"]' do
            Role.all.each do |role|
              assert_select 'option', role.name
            end
          end
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_user_url(@user)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit User'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form' do
          assert_select 'input[name="user[first_name]"][value=?]', @user.first_name
          assert_select 'input[name="user[last_name]"][value=?]', @user.last_name
          assert_select 'input[name="user[email]"][value=?]', @user.email
          assert_select 'input[name="user[password]"]'
          assert_select 'select[name="user[role_ids][]"]' do
            @user.roles.each do |role|
              assert_select 'option[selected="selected"]', role.name
            end
          end
        end
      end
    end
  end
end
