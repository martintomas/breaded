# frozen_string_literal: true

require 'test_helper'

class SidekiqMonitoringControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'admin is allowed to see sidekiq monitoring view' do
    sign_in users(:admin)
    get sidekiq_web_url
    assert_response :success
  end

  test 'customer is not allowed to use sidekiq monitoring view' do
    sign_in users(:customer)
    assert_raise(ActionController::RoutingError) { get sidekiq_web_url }
  end

  test 'not logged user gets redirected' do
    get sidekiq_web_url
    follow_redirect!
    assert_response :success
  end
end
