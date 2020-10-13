# frozen_string_literal: true

require "application_system_test_case"

class FoodsSystemTest < ApplicationSystemTestCase
  test '#index - load breads' do
    visit foods_path

    within 'div.itemsBlock' do
      assert_selector 'h5 > span.dd', text: I18n.t('app.browse_bread.filter.all')
      assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: Food.count)
      Food.all.sort_by(&:localized_name).each_with_index do |food, index|
        within "ul.itemsection:nth-of-type(#{index + 1})" do
          within 'li:nth-of-type(1)' do
            assert_selector "img[src='#{Blobs::UrlBuilder.new(food.image_detail).url}']"
            within 'div.iteamcount' do
              assert_selector 'span', text: I18n.t('app.browse_bread.about_bread')
              within '.numbers-row' do
                assert_equal 0.to_s, find('input[type="text"]').value
              end
            end
          end
          within 'li:nth-of-type(2)' do
            assert_selector 'span.lastWord', text: name_of(food)
            assert_selector 'p', text: food.tags.ingredients.map(&:localized_name).join(', ') if food.tags.ingredients.present?
          end
        end
      end
    end
  end

  test '#index - load bakers' do
    visit foods_path
    find('li#bakers').click

    within 'div.itemsBlock' do
      Producer.order(:id).all do |producer|
        assert_selector 'h5', text: producer.localized_name
        assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: producer.foods.size)
        assert_selector 'p', text: producer.localized_description
      end
    end
  end

  test '#index - breads filter' do
    visit foods_path

    within 'ul.listItems.breadsList' do
      assert_selector 'li.active > a', text: I18n.t('app.browse_bread.filter.all')
    end
    within 'div.itemsBlock' do
      assert_selector 'h5 > span.dd', text: I18n.t('app.browse_bread.filter.all')
      assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: Food.count)
      assert_text name_of(foods(:rye_bread))
      assert_text name_of(foods(:seeded_bread))
    end

    tag = tags(:rye_tag)
    click_on tag.localized_name

    within 'ul.listItems.breadsList' do
      assert_selector 'li.active > a', text: tag.localized_name
      assert_selector 'li.active > a', count: 1
    end
    within 'div.itemsBlock' do
      assert_selector 'h5 > span.dd', text: tag.localized_name
      assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: Food.joins(:tags).where(tags: { id: tag.id }).count)
      assert_text name_of(foods(:rye_bread))
      assert_text name_of(foods(:seeded_bread)), count: 0
    end
  end

  test '#index - bakers filter' do

  end

  test '#index - manipulate with shopping basket' do

  end

  test '#show - manipulate with shopping basket' do

  end

  test '#surprise_me - add ingredient' do

  end

  test '#surprise_me - add preferred bread type' do

  end

  private

  def name_of(food)
    food_name = food.localized_name.split(' ')
    "#{food_name[0..-2].join(' ')}\n#{food_name.last}"
  end
end
