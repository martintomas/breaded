# frozen_string_literal: true

require 'test_helper'

class  Stripe::UpdateCustomerJobTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @user = users :customer
  end

  test '#perform - updates user if stripe customer is not empty' do
    @user.update! stripe_customer: 'test'

    Stripe::Customer.stub :update, true, ['test', email: @user.email] do
      Stripe::UpdateCustomerJob.perform_now @user
    end
  end

  test '#perform - updates new user with stripe customer id' do
    Stripe::Customer.stub :create, OpenStruct.new(id: 'test'), [email: @user.email] do
      assert_enqueued_jobs 0 do
        Stripe::UpdateCustomerJob.perform_now @user

        assert_equal 'test', @user.reload.stripe_customer
      end
    end
  end
end
