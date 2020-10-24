# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'webmock/minitest'
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/mock'

Minitest::Reporters.use!

allowed_sites = [Regexp.new('chromedriver.storage.googleapis.com')]
allowed_sites += [Regexp.new(ENV['SELENIUM_URL'])] if ENV['SELENIUM_URL'].present?
WebMock.disable_net_connect!(allow_localhost: true, allow: allowed_sites)

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # @param [Symbol] attribute
  # @param [Class] klass of ApplicationRecord
  def invalid_with_missing(klass, attribute)
    @full_content.delete attribute
    model = klass.new @full_content
    refute model.valid?
    assert model.errors.include?(attribute)
  end

  # @param [Symbol] attribute
  # @param [Class] klass of ApplicationRecord
  def already_taken_unique(klass, attribute)
    klass.create! @full_content
    new_type = klass.new @full_content
    refute new_type.valid?
    assert new_type.errors.include?(attribute), new_type.errors.keys.inspect
    assert_equal :taken, new_type.errors.details[attribute][0][:error]
  end
end
