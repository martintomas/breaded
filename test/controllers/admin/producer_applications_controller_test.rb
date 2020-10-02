# frozen_string_literal: true

require 'test_helper'

class Admin::ProducerApplicationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @producer_application = producer_applications :producer_application_bread_and_butter
  end

  test '#index' do
    get admin_producer_applications_url

    assert_response :success
  end

  test '#show' do
    get admin_producer_application_url(@producer_application)

    assert_response :success
  end

  test '#destroy' do
    assert_difference 'ProducerApplication.count', -1 do
      delete admin_producer_application_url(@producer_application)

      assert_redirected_to admin_producer_applications_url
    end
  end
end
