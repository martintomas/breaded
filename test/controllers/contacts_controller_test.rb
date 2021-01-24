# frozen_string_literal: true

require 'test_helper'

class ContactsControllerTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_contact_path
    assert_response :success
  end

  test '#create' do
    post contacts_path, params: { contacts: { message: 'Can somebody help me?' } }
    assert_redirected_to new_contact_path
  end
end
