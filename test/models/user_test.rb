# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @full_content = { first_name: 'Super',
                      last_name: 'Admin',
                      email: 'new.admin@breaded.net',
                      password: 'password' }
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

  test '#current_ability' do
    assert_equal Ability, @user.current_ability.class
  end

  test '#to_s' do
    assert_equal "#{@user.first_name} #{@user.last_name} (#{@user.email})", @user.to_s
  end
end
