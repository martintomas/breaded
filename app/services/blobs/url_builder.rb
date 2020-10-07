# frozen_string_literal: true

class Blobs::UrlBuilder
  include Rails.application.routes.url_helpers

  attr_accessor :blob

  def initialize(blob, **options)
    @blob = blob
  end

  def url
    # TODO: use cdn after active storage allows to do public save
    rails_blob_url blob, host: Rails.application.routes.default_url_options[:host]
  end
end
