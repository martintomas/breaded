# frozen_string_literal: true

require 'test_helper'

class PagesTest < ActionDispatch::IntegrationTest
  test '#home' do
    get root_url

    assert_select 'body' do
      assert_select 'h1', 'Breaded'
    end
  end
end
