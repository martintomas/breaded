# frozen_string_literal: true

require 'test_helper'

class Admin::PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:admin)
    @payment = payments :payment_1
  end

  test '#index' do
    get admin_payments_url

    assert_response :success
  end

  test '#show' do
    get admin_payment_url(@payment)

    assert_response :success
  end
end
