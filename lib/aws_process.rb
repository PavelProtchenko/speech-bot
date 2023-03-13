# frozen_string_literal: true

require 'aws-sdk-s3'
require 'dotenv'

class AwsProcess
  class << self
    def call(file_content)
      connect
      send_file(file_content)
    end

    private

    def send_file(file_content)
      File.open('audio_file.ogg', 'wb') do
        Aws::S3::Client.new.put_object({ bucket: ENV['S3_BUCKET_NAME'], key: 'audio_file.ogg', body: file_content })
      end
    end

    def connect
      Aws.config.update(
        region: ENV['S3_BUCKET_REGION'],
        endpoint: ENV['S3_ENDPOINT'],
        access_key_id: ENV['S3_ACCESS_KEY'],
        secret_access_key: ENV['S3_SECRET_KEY'],
        force_path_style: true
      )
    end
  end
end
