# frozen_string_literal: true

require 'test_helper'

class Admin::AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @availability = availabilities :availability_monday
  end

  test '#index' do
    get admin_availabilities_url

    assert_response :success
  end

  test '#show' do
    get admin_availability_url(@availability)

    assert_response :success
  end

  test '#new' do
    get new_admin_availability_url

    assert_response :success
  end

  test '#edit' do
    get edit_admin_availability_url(@availability)

    assert_response :success
  end

  test '#create' do
    assert_difference 'Availability.count', 1 do
      post admin_availabilities_url, params: { availability: { day_in_week: 3,
                                                               time_from: Time.find_zone("UTC").parse("10:00"),
                                                               time_to: Time.find_zone("UTC").parse("14:00") }}

      availability = Availability.last
      assert_equal 3, availability.day_in_week
      assert_equal Time.find_zone("UTC").parse("10:00").to_s(:time), availability.time_from.to_s(:time)
      assert_equal Time.find_zone("UTC").parse("14:00").to_s(:time), availability.time_to.to_s(:time)
      assert_redirected_to admin_availability_url(availability)
    end
  end

  test '#update' do
    patch admin_availability_url(@availability), params: { availability: { day_in_week: 5 } }

    @availability.reload
    assert_equal 5, @availability.day_in_week
    assert_redirected_to admin_availability_url(@availability)
  end

  test '#destroy' do
    assert_difference 'Availability.count', -1 do
      delete admin_availability_url(@availability)

      assert_redirected_to admin_availabilities_url
    end
  end
end
