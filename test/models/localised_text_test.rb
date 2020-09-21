# frozen_string_literal: true

require 'test_helper'

class LocalisedTextTest < ActiveSupport::TestCase
  setup do
    @full_content = {}
  end

  test 'the validity - with all is valid' do
    model = LocalisedText.new @full_content
    assert model.valid?, model.errors.full_messages
  end
end
