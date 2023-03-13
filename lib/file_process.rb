# frozen_string_literal: true

require 'httparty'
require 'json'
require 'uri'

require_relative 'aws_process'

class FileProcess
  def self.call(message, telegram_token)
    download_voice_file(message, telegram_token)
  end

  class << self

    private

    def download_voice_file(message, telegram_token)
      response = file_reciever(message, telegram_token)
      file_path = JSON.parse(response.body)['result']['file_path']
      file_content = HTTParty.get("https://api.telegram.org/file/bot#{telegram_token}/#{file_path}")&.body

      # AwsProcess
      AwsProcess.call(file_content)
    end

    def file_reciever(message, telegram_token)
      url = URI("https://api.telegram.org/bot#{telegram_token}/getFile")
      headers = {
        'Content-Type' => 'application/json'
      }

      body = "{\"file_id\":\"#{message.voice.file_id}\"}"

      HTTParty.post(url, headers: headers, body: body)
    end
  end
end
