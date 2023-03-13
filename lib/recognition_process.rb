# frozen_string_literal: true

require 'dotenv/load'
require 'json'
require 'uri'

class RecognitionProcess
  class << self
    def call
      send_to_speech_encode
      parse_response(send_to_speech_encode)
    end

    private

    def send_to_speech_encode
      url = URI('https://stt.api.cloud.yandex.net/speech/v1/stt:recognize')
      params = {
        :folderId => 'b1ghan15afu8o5l3hhev',
        :lang => 'ru-RU',
      }
      url.query = URI.encode_www_form(params)

      headers = {
        'Content-Type' => 'application/octet-stream;Transfer-Encoding: chunked',
        'Authorization' => "Bearer #{ENV['YANDEX_API_KEY']}"
      }

      res = HTTParty.get('https://storage.yandexcloud.net/speech-test-bot/audio_file.ogg')

      HTTParty.post(url, headers: headers, body: res.response.body)
    end

    def parse_response(res)
      JSON.parse(res.body)['result']
    end
  end
end
