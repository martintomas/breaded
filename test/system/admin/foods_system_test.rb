# frozen_string_literal: true

require "application_system_test_case"

class Admin::FoodsSystemTest < ApplicationSystemTestCase
  setup do
    login_as_admin
    @food = foods :rye_bread
  end

  test '#create' do
    visit new_admin_food_url

    within 'form#new_food' do
      fill_in 'food[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      fill_in 'food[description_attributes][text_translations_attributes][0][text]', with: 'Test Description'
      select Producer.first.localized_name, from: 'food[producer_id]'
      attach_file 'food[image_detail]', file_fixture('product-1.png')
      attach_file 'food[image_description]', file_fixture('product-1.png')
      check 'food[enabled]'
      check "food_tag_ids_#{Tag.first.id}"
      check "food_tag_ids_#{Tag.last.id}"
      click_on 'Create Food'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: 'Test Description'
            assert_selector 'td', text: Producer.first.localized_name
          end
        end
        assert_selector 'td', text: Tag.first.localized_name
        assert_selector 'td', text: Tag.last.localized_name
      end
    end
  end

  test '#update' do
    visit edit_admin_food_url(@food)

    within "form#edit_food_#{@food.id}" do
      fill_in 'food[name_attributes][text_translations_attributes][0][text]', with: 'Test Name'
      fill_in 'food[description_attributes][text_translations_attributes][0][text]', with: 'Test Description'
      select Producer.first.localized_name, from: 'food[producer_id]'
      check 'food[enabled]'
      check "food_tag_ids_#{Tag.first.id}"
      check "food_tag_ids_#{Tag.last.id}"
      click_on 'Update Food'
    end
    within 'div#active_admin_content' do
      within 'div#main_content' do
        within 'div.panel:nth-of-type(1)' do
          within 'table' do
            assert_selector 'td', text: 'Test Name'
            assert_selector 'td', text: 'Test Description'
            assert_selector 'td', text: Producer.first.localized_name
          end
        end
        @food.tags.reload.each do |tag|
          assert_selector 'td', text: tag.localized_name
        end
      end
    end
  end
end
