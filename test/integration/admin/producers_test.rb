# frozen_string_literal: true

require 'test_helper'

class Admin::ProducersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @producer = producers :bread_and_butter
  end

  test 'is shown at menu' do
    get admin_producers_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.producer')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.producers.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_producers_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.producers.label')
    end
  end

  test '#index' do
    get admin_producers_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_producers' do
            Producer.all.each do |producer|
              assert_select 'tr' do
                assert_select 'td', producer.localized_name
                assert_select 'td', producer.localized_description
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_producer_url(@producer)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @producer.localized_name
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @producer.localized_name
            assert_select 'td', @producer.localized_description
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_producer_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Producer'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_producer' do
          assert_select 'textarea[name="producer[name_attributes][text_translations_attributes][0][text]"]'
          assert_select 'textarea[name="producer[description_attributes][text_translations_attributes][0][text]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_producer_url(@producer)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Producer'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_producer_#{@producer.id}" do
          assert_select 'textarea[name="producer[name_attributes][text_translations_attributes][0][text]"]',
                        @producer.localized_name
          assert_select 'textarea[name="producer[description_attributes][text_translations_attributes][0][text]"]',
                        @producer.localized_description
        end
      end
    end
  end
end
