# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test '.required_field' do
    assert_equal content_tag(:sup, '*'), required_field
  end
end
