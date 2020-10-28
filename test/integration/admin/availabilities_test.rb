# frozen_string_literal: true

require 'test_helper'

class Admin::AvailabilitiesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @availability = availabilities :availability_monday
  end

  test 'is shown at menu' do
    get admin_availabilities_url
    assert_select 'div.header' do
      assert_select 'li.menu_item.current' do
        assert_select 'a', I18n.t('active_admin.menu.parents.availability')
        assert_select 'ul.menu' do
          assert_select 'li', I18n.t('active_admin.availabilities.label')
        end
      end
    end
  end

  test 'shows proper title' do
    get admin_availabilities_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', I18n.t('active_admin.availabilities.label')
    end
  end

  test '#index' do
    get admin_availabilities_url
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.paginated_collection' do
          assert_select 'table#index_table_availabilities' do
            Availability.all.each do |availability|
              assert_select 'tr' do
                assert_select 'td', availability.day_in_week.to_s
                assert_select 'td', availability.time_from.strftime( "%H:%M")
                assert_select 'td', availability.time_to.strftime( "%H:%M")
              end
            end
          end
        end
      end
    end
  end

  test '#show' do
    get admin_availability_url(@availability)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', "Availability ##{@availability.id}"
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'div.panel_contents' do
          assert_select 'table' do
            assert_select 'td', @availability.day_in_week.to_s
            assert_select 'td', @availability.time_from.strftime( "%H:%M")
            assert_select 'td', @availability.time_to.strftime( "%H:%M")
          end
        end
      end
    end
  end

  test '#new' do
    get new_admin_availability_url
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'New Availability'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select 'form#new_availability' do
          assert_select 'input[name="availability[day_in_week]"]'
        end
      end
    end
  end

  test '#edit' do
    get edit_admin_availability_url(@availability)
    assert_select 'div.title_bar' do
      assert_select 'h2#page_title', 'Edit Availability'
    end
    assert_select 'div#active_admin_content' do
      assert_select 'div#main_content' do
        assert_select "form#edit_availability" do
          assert_select 'input[name="availability[day_in_week]"][value=?]', @availability.day_in_week.to_s
        end
      end
    end
  end
end
