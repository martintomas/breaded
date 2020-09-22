# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  test '#home' do
    get root_url
    assert_response :success
  end

  test '#commit' do
    get commit_pages_url
    assert_response :success
    assert_match /test/, response.body
  end
end
