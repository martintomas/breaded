# frozen_string_literal: true

require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users :customer
  end

  test '#new' do
    get new_contact_path
    assert_response :success
  end

  test '#create' do
    post contacts_path, params: { contacts: { message: 'Can somebody help me?' } }
    assert_redirected_to new_contact_path
  end

  test '#support' do
    sign_in @user
    get support_contacts_path
    assert_response :success
  end

  test '#send_support_message' do
    sign_in @user
    post send_support_message_contacts_path, params: { contacts: { message: 'Can somebody help me?',
                                                                   subscription_period_id: subscription_periods(:customer_1_subscription_1_period).id,
                                                                   order_id: orders(:customer_order_1).id } }
    assert_redirected_to support_contacts_path
  end
end
