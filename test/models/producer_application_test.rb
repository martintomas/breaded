# frozen_string_literal: true

require 'test_helper'

class ProducerApplicationTest < ActiveSupport::TestCase
  setup do
    @full_content = { first_name: 'First Name',
                      last_name: 'Last Name',
                      email: 'test@test.test',
                      phone_number: '12346698' }
  end

  test 'the validity - empty is not valid' do
    model = ProducerApplication.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = ProducerApplication.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without first_name is not valid' do
    invalid_with_missing ProducerApplication, :first_name
  end

  test 'the validity - without last_name is not valid' do
    invalid_with_missing ProducerApplication, :last_name
  end

  test 'the validity - without email is not valid' do
    invalid_with_missing ProducerApplication, :email
  end

  test 'the validity - without phone_number is not valid' do
    invalid_with_missing ProducerApplication, :phone_number
  end
end
