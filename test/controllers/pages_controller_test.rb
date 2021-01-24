# frozen_string_literal: true

require 'test_helper'

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
  end

  test '#home' do
    get root_url
    assert_response :success
  end

  test '#about' do
    get about_pages_url
    assert_response :success
  end

  test '#faq' do
    sign_in @user
    get faq_pages_url
    assert_response :success
  end
end
