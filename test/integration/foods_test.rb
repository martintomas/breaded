# frozen_string_literal: true

require 'test_helper'

class FoodsTest < ActionDispatch::IntegrationTest
  include ActionView::Helpers::SanitizeHelper

  test '#index - contains menu' do
    get foods_path

    assert_select 'div.pickup' do
      assert_select 'h1', I18n.t('app.browse_bread.title')
      assert_select 'p', I18n.t('app.browse_bread.subtitle')
      assert_select 'div#tab-container' do
        assert_select 'div.panel-switch' do
          assert_select 'button#letMe', I18n.t('app.browse_bread.menu_let_me')
          assert_select 'button.active-button#suprise', I18n.t('app.browse_bread.menu_surprise_me')
        end
      end
    end
  end

  test '#index - contains filter for desktop version' do
    get foods_path

    assert_select 'div.pickup' do
      assert_select 'div.filterSetion' do
        assert_select 'span', I18n.t('app.browse_bread.filter.label')
        assert_select 'ul.bakersBread' do
          assert_select 'li#breads', I18n.t('app.browse_bread.filter.bread_section')
          assert_select 'li#bakers', I18n.t('app.browse_bread.filter.bakers_section')
        end
        assert_select 'ul.listItems.breadsList' do
          assert_select 'a', I18n.t('app.browse_bread.filter.all')
          assert_select 'a', tags(:featured).localized_name
          Tag.categories.each do |tag|
            assert_select 'li' do
              assert_select 'a', tag.localized_name
            end
          end
        end
        assert_select 'ul.listItems.bakersList' do
          assert_select 'a', I18n.t('app.browse_bread.filter.all')
          Producer.all.each do |producer|
            assert_select 'li' do
              assert_select 'a', producer.localized_name
            end
          end
        end
      end
    end
  end

  test '#index - contains filter for mobile version' do
    get foods_path

    assert_select 'section.main' do
      assert_select 'ul.dropdown.breadsListMob' do
        assert_select 'a', I18n.t('app.browse_bread.filter.all')
        assert_select 'a', tags(:featured).localized_name
        Tag.categories.each do |tag|
          assert_select 'li' do
            assert_select 'a', tag.localized_name
          end
        end
      end
      assert_select 'ul.dropdown.bakersListMob' do
        assert_select 'a', I18n.t('app.browse_bread.filter.all')
        Producer.all.each do |producer|
          assert_select 'li' do
            assert_select 'a', producer.localized_name
          end
        end
      end
    end
  end

  test '#index - contains shopping basket' do
    get foods_path

    assert_select 'div.selectedItems.sticker' do
      assert_select 'span', "0/#{Rails.application.config.options[:default_number_of_breads]}"
      assert_select 'i.size-of-basket', 0.to_s
      assert_select 'span.no-breads-title', I18n.t('app.browse_bread.shopping_basket.empty')
      assert_select 'div#shopping-basket' do
        assert_select 'span', Regexp.new(strip_tags(I18n.t('app.browse_bread.shopping_basket.breads_selected_html')))
        assert_select 'i.open-basket-button', I18n.t('app.browse_bread.shopping_basket.open_button')
        assert_select 'i.close-basket-button', I18n.t('app.browse_bread.shopping_basket.close_button')
        assert_select 'div.shopping-basket-items'
      end
    end
  end

  test '#show' do
    food = foods :rye_bread
    get food_path(food)

    assert_select 'div.breadDescription' do
      assert_select 'ul.breadcrumbs' do
        assert_select 'li', I18n.t('app.menu.browse_breads')
        assert_select 'li', food.localized_name
      end
      assert_select 'img[src=?]', Blobs::UrlBuilder.new(food.image_description).url
      assert_select 'section.breadDetails' do
        assert_select 'h3', food.localized_name
        assert_select 'p', tags(:honey_tag).localized_name
        assert_select 'div', 'V' + tags(:vegetarian_tag).localized_name
        assert_select 'div' do
          assert_select 'h4', I18n.t('app.bread_detail.goes_well_with')
          assert_select 'p', tags(:butter_tag).localized_name
        end
        assert_select 'div' do
          assert_select 'h4', I18n.t('app.bread_detail.baked_by')
          assert_select 'p', food.producer.localized_name
        end
        assert_select 'div' do
          assert_select 'h4', I18n.t('app.bread_detail.add')
          assert_select 'div.numbers-row' do
            assert_select 'div.dec.button', '-'
            assert_select 'input[type="text" ][value=?]', 0.to_s
            assert_select 'div.inc.button', '+'
          end
        end
      end
      assert_select 'div.description' do
        assert_select 'h3', I18n.t('app.browse_bread.about_bread')
        assert_select 'p', food.localized_description
      end
    end
  end

  test '#surprise_me - contains menu' do
    get surprise_me_foods_path

    assert_select 'div.pickup' do
      assert_select 'h1', I18n.t('app.browse_bread.title')
      assert_select 'p', I18n.t('app.browse_bread.subtitle')
      assert_select 'div#tab-container' do
        assert_select 'div.panel-switch' do
          assert_select 'button.active-button#letMe', I18n.t('app.browse_bread.menu_let_me')
          assert_select 'button#suprise', I18n.t('app.browse_bread.menu_surprise_me')
        end
      end
    end
  end

  test '#surprise_me' do
    get surprise_me_foods_path

    assert_select 'div.surpriseSection' do
      assert_select 'h4', strip_tags(I18n.t('app.surprise_me.ingredients_preferences_html'))
      assert_select 'span' do
        Tag.attributes.each do |tag|
          assert_select 'li', tag.code[0].upcase
          assert_select 'li', tag.localized_name
          assert_select 'div.numbers-row' do
            assert_select 'div.inc.button', '+'
            assert_select 'input[type="text" ][value=?]', 0.to_s
            assert_select 'div.dec.button', '-'
          end
        end
      end
      assert_select 'h4', strip_tags(I18n.t('app.surprise_me.favourite_bread_types_html'))
      assert_select 'div.checkBoxSection' do
        Tag.categories.each do |tag|
          assert_select 'label.baker_container', Regexp.new(tag.localized_name)
        end
      end
      assert_select 'div.surpriseList' do
        assert_select 'h4', strip_tags(I18n.t('app.surprise_me.let_us_surprise_you_html'))
        assert_select 'div.ingredients-preference' do
          assert_select 'span', I18n.t('app.surprise_me.ingredients_preferences')
        end
        assert_select 'div.favourite_bread_types' do
          assert_select 'span', I18n.t('app.surprise_me.favourite_bread_types')
        end
        assert_select 'button', I18n.t('app.surprise_me.confirm')
      end
    end
  end
end
