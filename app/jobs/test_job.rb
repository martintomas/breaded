# frozen_string_literal: true

class TestJob < ApplicationJob
  queue_as :default

  def perform(raise_exception: false)
    raise StandardError, 'test of exception' if raise_exception

    TestMailer.test.deliver_later
  end
end
