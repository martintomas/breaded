# frozen_string_literal: true

require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  setup do
    @full_content = { user: users(:customer),
                      subscription_plan: subscription_plans(:once_every_month),
                      surprise_me_count: 0,
                      active: true }
  end

  test 'the validity - empty is not valid' do
    model = Subscription.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = Subscription.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without user is not valid' do
    invalid_with_missing Subscription, :user
  end

  test 'the validity - without subscription_plan is not valid' do
    invalid_with_missing Subscription, :subscription_plan
  end

  test 'the validity - without surprise_me_count is valid' do
    model = Subscription.new @full_content.except(:surprise_me_count)
    assert model.valid?, model.errors.full_messages
    assert_equal model.surprise_me_count, 0
  end

  test 'the validity - without active is valid' do
    model = Subscription.new @full_content.except(:active)
    assert model.valid?, model.errors.full_messages
    assert model.active
  end
end
