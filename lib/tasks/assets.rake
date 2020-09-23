# frozen_string_literal: true

require 'aws-sdk-s3'

namespace :assets do
  task :to_cdn, [] => :environment do
    s3 = Aws::S3::Resource.new(region: 'ams3',
                               access_key_id: ENV["STORAGE_KEY"],
                               secret_access_key: ENV["STORAGE_ACCESS_KEY"],
                               endpoint: ENV["STORAGE_ENDPOINT"])

    Dir.glob('**/*', base: 'public').each do |public_asset|
      path = Rails.root.join 'public', public_asset
      next unless File.file? path

      obj = s3.bucket(ENV["STORAGE_BUCKET"]).object(public_asset)
      obj.put(acl: 'public-read', body: File.open(path))
    end
  end
end
