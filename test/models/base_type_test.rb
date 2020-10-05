# frozen_string_literal: true

require 'test_helper'

class BaseTypeTest < ActiveSupport::TestCase
  setup do
    @model = Language.first
  end
  
  test '#to_s' do
    assert_equal @model.code, @model.to_s
  end
end
