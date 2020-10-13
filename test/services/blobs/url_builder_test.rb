# frozen_string_literal: true

require 'test_helper'

class Blobs::UrlBuilderTest < ActiveSupport::TestCase
  include Rails.application.routes.url_helpers

  setup do
    @blob = foods(:rye_bread).image_detail
    @url_builder = Blobs::UrlBuilder.new @blob
  end

  test '#url' do
    assert_equal rails_blob_url(@blob, host: Rails.application.routes.default_url_options[:host]),
                 @url_builder.url
  end
end
