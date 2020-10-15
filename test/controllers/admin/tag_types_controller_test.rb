# frozen_string_literal: true

require 'test_helper'

class Admin::TagTypesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @tag_type = tag_types :ingredient
  end

  test '#index' do
    get admin_tag_types_url

    assert_response :success
  end

  test '#show' do
    get admin_tag_type_url(@tag_type)

    assert_response :success
  end

  test '#new' do
    get new_admin_tag_type_url

    assert_response :success
  end

  test '#create' do
    assert_difference 'TagType.count', 1 do
      post admin_tag_types_url, params: { tag_type: { code: 'NEW TAG TYPE' } }

      tag_type = TagType.last
      assert_equal tag_type.code, 'NEW TAG TYPE'
      assert_redirected_to admin_tag_type_url(tag_type)
    end
  end

  test '#update' do
    patch admin_tag_type_url(@tag_type), params: { tag_type: { code: 'UPDATED TAG TYPE' } }

    assert_equal @tag_type.reload.code, 'UPDATED TAG TYPE'
    assert_redirected_to admin_tag_type_url(@tag_type)
  end

  test '#destroy' do
    assert_difference 'TagType.count', -1 do
      delete admin_tag_type_url(@tag_type)

      assert_redirected_to admin_tag_types_url
    end
  end
end
