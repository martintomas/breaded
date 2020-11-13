# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @full_content = { first_name: 'Super',
                      last_name: 'Admin',
                      email: 'new.admin@breaded.net',
                      password: 'password',
                      phone_number: '+420734370408',
                      unconfirmed_phone: '+420734370408',
                      secondary_phone_number: '+420734370408' }
    @user = users :customer
  end

  test 'the validity - empty is not valid' do
    model = User.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = User.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without first_name is not valid' do
    invalid_with_missing User, :first_name
  end

  test 'the validity - without last_name is not valid' do
    invalid_with_missing User, :last_name
  end

  test 'the validity - without email is not valid' do
    invalid_with_missing User, :email
  end

  test 'the validity - without password is not valid' do
    invalid_with_missing User, :password
  end

  test 'the validity email needs to be unique' do
    already_taken_unique User, :email
  end

  test 'the validity - without phone_number is valid' do
    model = User.new @full_content.except(:phone_number)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without unconfirmed_phone is valid' do
    model = User.new @full_content.except(:unconfirmed_phone)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without secondary_phone_number is valid' do
    model = User.new @full_content.except(:secondary_phone_number)
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - phone number has to be valid' do
    @full_content[:phone_number] = '123456789'
    model = User.new @full_content
    refute model.valid?
    assert model.errors.include?(:phone_number)
  end

  test '#phony_normalize of phone number' do
    @full_content[:phone_number] = '420 734 370 408'
    model = User.new @full_content
    assert_equal '+420734370408', model.normalized_phone_number
  end

  test '#phony_normalize of unconfirmed phone number' do
    @full_content[:unconfirmed_phone] = '420 734 370 408'
    model = User.new @full_content
    assert_equal '+420734370408', model.normalized_unconfirmed_phone
  end

  test '#phony_normalize of secondary phone number' do
    @full_content[:secondary_phone_number] = '420 734 370 408'
    model = User.new @full_content
    assert_equal '+420734370408', model.normalized_secondary_phone_number
  end

  test '#current_ability' do
    assert_equal Ability, @user.current_ability.class
  end

  test '#address - return main address always' do
    assert_equal addresses(:customer_address), @user.address
  end

  test '#address - return first available address when main address is missing' do
    addresses(:customer_address).delete
    assert_equal addresses(:customer_address_1), @user.address
  end

  test '#stripe_sync - is triggered after create' do
    assert_enqueued_jobs 1, only: Stripe::UpdateCustomerJob do
      User.create! @full_content
    end
  end

  test '#stripe_sync - is triggered when email is updated' do
    assert_enqueued_jobs 1, only: Stripe::UpdateCustomerJob do
      @user.skip_reconfirmation!
      @user.update! email: 'new.email@test.test'
    end
  end

  test '#stripe_sync - is not triggered when different field of user is updated' do
    assert_no_enqueued_jobs only: Stripe::UpdateCustomerJob do
      @user.update! first_name: 'New Name'
    end
  end

  test '#stripe_sync - is not triggered on destroy' do
    assert_no_enqueued_jobs only: Stripe::UpdateCustomerJob do
      users(:admin).destroy!
    end
  end

  test '#full_name' do
    assert_equal "#{@user.first_name} #{@user.last_name}", @user.full_name
  end

  test '#payment_method - is empty when user has not stripe account' do
    @user.update! stripe_customer: nil

    assert_nil @user.payment_method
  end

  test '#payment_method - returns payment method' do
    @user.update! stripe_customer: 'stripe_customer_id'

    Stripe::Customer.stub :retrieve, OpenStruct.new(invoice_settings: OpenStruct.new(default_payment_method: 'payment_method')),
                          [id: 'stripe_customer_id', expand: ['invoice_settings.default_payment_method']] do
      assert_equal 'payment_method', @user.payment_method
    end
  end

  test '#to_s' do
    assert_equal "#{@user.first_name} #{@user.last_name} (#{@user.email})", @user.to_s
  end
end
