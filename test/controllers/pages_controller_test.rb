# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test '#home' do
    get root_url
    assert_response :success
  end
end
