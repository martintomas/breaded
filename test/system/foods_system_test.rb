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
              within '.numbers-row' do
                assert_equal 0.to_s, find('input[type="text"]').value
              end
            end
          end
          within 'li:nth-of-type(2)' do
            assert_selector 'span.lastWord', text: food.localized_name
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
      Producer.order(:id).all.each do |producer|
        assert_selector 'h5', text: producer.localized_name
        assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: producer.foods.size)
        assert_selector 'p', text: producer.localized_description
      end
    end
  end

  test '#index - breads filter' do
    tag = tags(:rye_tag)
    visit foods_path

    within 'div.browse_bread.active' do
      within 'ul.listItems.breadsList' do
        assert_selector 'li.active > a', text: I18n.t('app.browse_bread.filter.all')
      end
      within 'div.itemsBlock' do
        assert_selector 'h5 > span.dd', text: I18n.t('app.browse_bread.filter.all')
        assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: Food.count)
        assert_text foods(:rye_bread).localized_name
        assert_text foods(:seeded_bread).localized_name
      end
    end

    within 'ul.listItems.breadsList' do
      click_on tag.localized_name
    end

    within 'div.browse_bread.active' do
      within 'ul.listItems.breadsList' do
        assert_selector 'li.active > a', text: tag.localized_name
        assert_selector 'li.active > a', count: 1
      end
      within 'div.itemsBlock' do
        assert_selector 'h5 > span.dd', text: tag.localized_name
        assert_selector 'span', text: I18n.t('app.browse_bread.number_items', number: Food.joins(:tags).where(tags: { id: tag.id }).count)
        assert_text foods(:rye_bread).localized_name
        assert_text foods(:seeded_bread).localized_name, count: 0
      end
    end
  end

  test '#index - bakers filter' do
    visit foods_path
    find('li#bakers').click

    within 'div.browse_bread.active' do
      within 'ul.listItems.bakersList' do
        assert_selector 'li.active > a', text: I18n.t('app.browse_bread.filter.all')
      end
      within 'div.itemsBlock' do
        assert_selector 'h5', count: Producer.count
        Producer.all.each do |producer|
          assert_text producer.localized_name
        end
      end
    end

    producer = producers(:bread_and_butter)
    within 'ul.listItems.bakersList' do
      click_on producer.localized_name
    end

    within 'div.browse_bread.active' do
      within 'ul.listItems.bakersList' do
        assert_selector 'li.active > a', text: producer.localized_name
      end
      within 'div.itemsBlock' do
        assert_selector 'h5', count: 1
        assert_text producer.localized_name
      end
    end
  end

  test '#index - infinity scrolling' do
    20.times { Food.create! name: localised_texts(:rye_bread_name),
                            description: localised_texts(:rye_bread_description),
                            producer: producers(:bread_and_butter),
                            image_detail: ActiveStorage::Blob.find(1),
                            image_description: ActiveStorage::Blob.find(1) }

    visit foods_path

    within 'div.itemsBlock' do
      assert_selector 'ul.itemsection', count: 10
    end

    page.execute_script('document.getElementsByClassName("pagination")[0].scrollIntoView();')

    within 'div.itemsBlock' do
      assert_selector 'ul.itemsection', count: 20
    end
  end

  test '#index - manipulate with shopping basket' do
    visit foods_path

    within 'div#tab-content' do
      within 'div.selectedItems' do
        assert_selector 'i.size-of-basket', text: 0.to_s
        assert_selector 'span.no-breads-title',text:  I18n.t('app.browse_bread.shopping_basket.empty')
      end
    end

    food1 = foods(:rye_bread)
    food2 = foods(:seeded_bread)
    find("div.inc.button[data-food-id='#{food1.id}']", match: :first).click
    find("div.inc.button[data-food-id='#{food1.id}']", match: :first).click
    find("div.inc.button[data-food-id='#{food2.id}']", match: :first).click
    find("div.dec.button[data-food-id='#{food2.id}']", match: :first).click

    within 'div#tab-content' do
      within 'div.selectedItems' do
        assert_selector 'i.size-of-basket', text: 2.to_s
        assert_selector 'span.number-selected-breads', text: 1.to_s
        within 'div.shopping-basket-items' do
          assert_selector 'span.food-name', text: food1.localized_name
        end
      end
    end
  end

  test '#show - manipulate with shopping basket' do
    food = foods(:rye_bread)
    visit food_path(food)

    find("div.inc.button[data-food-id='#{food.id}']").click

    visit foods_path

    within 'div#tab-content' do
      within 'div.selectedItems' do
        assert_selector 'i.size-of-basket', text: 1.to_s
        assert_selector 'span.number-selected-breads', text: 1.to_s
        within 'div.shopping-basket-items' do
          assert_selector 'span.food-name', text: food.localized_name
        end
      end
    end
  end

  test '#surprise_me - add ingredient' do
    visit surprise_me_foods_path
    tag = tags(:vegetarian_tag)

    within 'div.surpriseSection' do
      within 'div.ingredients-preference' do
        assert_selector 'p', text: tag.localized_name, count: 0
      end

      find("div.inc.button[data-tag-id='#{tag.id}']").click
      find("div.inc.button[data-tag-id='#{tag.id}']").click
      find("div.dec.button[data-tag-id='#{tag.id}']").click

      within 'div.ingredients-preference' do
        assert_selector 'p', text: tag.localized_name
      end
    end
  end

  test '#surprise_me - add preferred bread type' do
    visit surprise_me_foods_path
    tag1 = tags(:rye_tag)
    tag2 = tags(:sourdough_tag)

    within 'div.surpriseSection' do
      within 'div.favourite_bread_types' do
        assert_selector 'p', text: tag1.localized_name, count: 0
        assert_selector 'p', text: tag2.localized_name, count: 0
      end

      find("input[type='checkbox'][data-tag-id='#{tag1.id}']").execute_script('this.click();')
      find("input[type='checkbox'][data-tag-id='#{tag2.id}']").execute_script('this.click();')
      find("input[type='checkbox'][data-tag-id='#{tag2.id}']").execute_script('this.click();')

      within 'div.favourite_bread_types' do
        assert_selector 'p', text: tag1.localized_name
        assert_selector 'p', text: tag2.localized_name, count: 0
      end
    end
  end
end
