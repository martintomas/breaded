# frozen_string_literal: true

require 'test_helper'

class Admin::FoodsTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @food = foods :rye_bread
  end

  test 'is shown at menu' do
    get admin_foods_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.producer')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.foods.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_foods_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.foods.label')
    end
  end

  test '#index' do
    get admin_foods_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_foods' do
            Food.all.each do |food|
              assert_select 'tr' do
                assert_select 'td', food.localized_name
                assert_select 'td', food.localized_description
                assert_select 'td', food.producer.localized_name
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_food_url(@food)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', @food.localized_name
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel' do
          assert_select 'table' do
            assert_select 'td', @food.localized_name
            assert_select 'td', @food.localized_description
            assert_select 'td', @food.producer.localized_name
          end
        end
      end
    end
  end

  test 'show - contains all tag sections' do
    get admin_food_url(@food)

    tag_types(:category, :goes_well, :attribute, :ingredient).each do |tag_type|
      assert_select 'div#active_admin_content' do
        assert_select 'div#main_content' do
          assert_select "div.panel##{tag_type.code.pluralize}" do
            assert_select 'table' do
              assert_select 'tr' do
                @food.tags.where(tag_type: tag_type).with_translations.each do |tag|
                  assert_select 'td', tag.localized_name
                end
              end
            end
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_food_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Food'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_food' do
          assert_select 'textarea[name="food[name_attributes][text_translations_attributes][0][text]"]'
          assert_select 'textarea[name="food[description_attributes][text_translations_attributes][0][text]"]'
          assert_select 'select[name="food[producer_id]"]'
          tag_types(:category, :goes_well, :attribute, :ingredient).each do |tag_type|
            Tag.where(tag_type: tag_type).each do |tag|
              assert_select "label[for=food_tag_ids_#{tag.id}]", tag.localized_name
              assert_select "input#food_tag_ids_#{tag.id}[type=checkbox]"
            end
          end
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_food_url(@food)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Food'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_food_#{@food.id}" do
          assert_select 'textarea[name="food[name_attributes][text_translations_attributes][0][text]"]',
                        @food.localized_name
          assert_select 'textarea[name="food[description_attributes][text_translations_attributes][0][text]"]',
                        @food.localized_description
          assert_select 'select[name="food[producer_id]"]' do
            assert_select 'option[selected=selected]', @food.producer.localized_name
          end
          tag_types(:category, :goes_well, :attribute, :ingredient).each do |tag_type|
            @food.tags.where(tag_type: tag_type).each do |tag|
              assert_select "label[for=food_tag_ids_#{tag.id}]", tag.localized_name
              assert_select "input#food_tag_ids_#{tag.id}[type=checkbox][checked=checked]"
            end
          end
        end
      end
    end
  end
end
