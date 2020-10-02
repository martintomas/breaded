# frozen_string_literal: true

require 'test_helper'

class ProducerApplicationsControllerTest < ActionDispatch::IntegrationTest
  test '#new' do
    get new_producer_application_path
    assert_response :success
  end

  test '#create' do
    assert_difference 'ProducerApplication.count', 1 do
      assert_difference 'EntityTag.count', 2 do
        post producer_applications_path, params: { producer_application: { first_name: 'First Name',
                                                                           last_name: 'Last Name',
                                                                           email: 'test@test.test',
                                                                           phone_number: '1234567',
                                                                           tag_ids: ['',
                                                                                     tags(:vegetarian_tag).id,
                                                                                     tags(:butter_tag).id] } }
        producer_application = ProducerApplication.last
        assert_equal 'First Name', producer_application.first_name
        assert_equal 'Last Name', producer_application.last_name
        assert_equal 'test@test.test', producer_application.email
        assert_equal '1234567', producer_application.phone_number
        assert_equal tags(:vegetarian_tag, :butter_tag), producer_application.tags
        assert_redirected_to new_producer_application_path
      end
    end
  end
end
