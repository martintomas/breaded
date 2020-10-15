require 'test_helper'

class SubscriptionSurpriseTest < ActiveSupport::TestCase
  setup do
    @full_content = { subscription: subscriptions(:surprise_me_subscription),
                      amount: 10,
                      tag: tags(:butter_tag) }
  end

  test 'the validity - empty is not valid' do
    model = SubscriptionSurprise.new
    refute model.valid?
  end

  test 'the validity - with all is valid' do
    model = SubscriptionSurprise.new @full_content
    assert model.valid?, model.errors.full_messages
  end

  test 'the validity - without subscription is not valid' do
    invalid_with_missing SubscriptionSurprise, :subscription
  end

  test 'the validity - without tag is not valid' do
    invalid_with_missing SubscriptionSurprise, :tag
  end

  test 'the validity - without amount is valid' do
    model = SubscriptionSurprise.new @full_content.except(:amount)
    assert model.valid?, model.errors.full_messages
    assert_nil model.amount
  end
end
