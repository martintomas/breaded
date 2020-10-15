# frozen_string_literal: true

require 'test_helper'

class Admin::TagTypesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @tag_type = tag_types :ingredient
  end

  test 'is shown at menu' do
    get admin_tag_types_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.tag')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.tag_types.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_tag_types_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.tag_types.label')
    end
  end

  test '#index' do
    get admin_tag_types_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_tag_types' do
            TagType.all.each do |tag_type|
              assert_select 'tr' do
                assert_select 'td', tag_type.code
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_tag_type_url(@tag_type)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @tag_type.code
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @tag_type.code
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_tag_type_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Tag Type'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_tag_type' do
          assert_select 'input[name="tag_type[code]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_tag_type_url(@tag_type)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Tag Type'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#edit_tag_type' do
          assert_select 'input[name="tag_type[code]"][value=?]', @tag_type.code
        end
      end
    end
  end
end
