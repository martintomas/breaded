# frozen_string_literal: true

require 'test_helper'

class Admin::TagsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @tag = tags :vegetarian_tag
  end

  test 'is shown at menu' do
    get admin_tags_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.tag')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.tags.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_tags_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.tags.label')
    end
  end

  test '#index' do
    get admin_tags_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_tags' do
            Tag.all.each do |tag|
              assert_select 'tr' do
                assert_select 'td', tag.localized_name
                assert_select 'td', tag.tag_type.to_s
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_tag_url(@tag)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @tag.localized_name
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @tag.localized_name
            assert_select 'td', @tag.tag_type.to_s
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_tag_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Tag'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_tag' do
          assert_select 'textarea[name="tag[name_attributes][text_translations_attributes][0][text]"]'
          assert_select 'select[name="tag[tag_type_id]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_tag_url(@tag)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Tag'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_tag_#{@tag.id}" do
          assert_select 'textarea[name="tag[name_attributes][text_translations_attributes][0][text]"]',
                        @tag.localized_name
          assert_select 'select[name="tag[tag_type_id]"]' do
            assert_select 'option[selected=selected]', @tag.tag_type.to_s
          end
        end
      end
    end
  end
end
