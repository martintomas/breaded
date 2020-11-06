# frozen_string_literal: true

require 'test_helper'

class FoodsControllerTest < ActionDispatch::IntegrationTest
  test '#index' do
    get foods_path
    assert_response :success
  end

  test '#index - json query for breads' do
    get foods_path, params: { section: 'breads', category: 'all' }, as: :json
    assert_response :success
    body = JSON.parse(response.body).symbolize_keys

    refute_nil body[:header]
    refute_nil body[:entries]
    refute_nil body[:pagination]
  end

  test '#index - json query for bakers' do
    get foods_path, params: { section: 'bakers', category: 'all' }, as: :json
    assert_response :success
    body = JSON.parse(response.body).symbolize_keys

    refute_nil body[:entries]
    refute_nil body[:pagination]
  end

  test '#show' do
    get food_path(foods(:rye_bread))
    assert_response :success
  end

  test '#show - raise forbidden when bread is disabled' do
    food = foods :rye_bread
    food.update! enabled: false

    get food_path(food)
    assert_redirected_to root_url
  end

  test '#surprise_me' do
    get surprise_me_foods_path
    assert_response :success
  end
end
