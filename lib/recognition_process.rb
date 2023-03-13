# frozen_string_literal: true

require 'dotenv/load'
require 'json'
require 'uri'

require_relative 'logger_process'

class RecognitionProcess
  WAIT_PERIOD = 2
  ATTEMPTS_COUNTER = 15

  class << self
    def call
      get_response(send_long_to_speech_encode)
    end

    private

    def send_long_to_speech_encode
      url = URI(ENV['YANDEX_SPEECH_ENCODE_URL'])

      options = {
        headers: {
          'Authorization' => "Api-Key #{ENV['YANDEX_API_KEY']}"
        },
        body: {
          'config' => {
            'specification' => {
              'languageCode' => 'ru-RU'
            }
          },
          'audio' => {
            'uri' => "#{ENV['S3_ENDPOINT']}/#{ENV['S3_BUCKET_NAME']}/audio_file.ogg"
          }
        }.to_json
      }

      HTTParty.post(url, options)['id']
    end

    def get_response(id)
      attempts = ATTEMPTS_COUNTER
      headers = {
        'Authorization' => "Bearer #{ENV['YANDEX_API_KEY_IAM_TOKEN']}"
      }
      url = "#{ENV['YANDEX_OPERATION_ENDPOINT']}/#{id}"

      while attempts.positive?
        response_from = HTTParty.get(url, headers: headers)

        sleep WAIT_PERIOD
        break if response_from['done'] == true

        attempts -= 1
      end
      LoggerProcess.call(response_from)

      response_from.dig('response', 'chunks')&.map { |el| el['alternatives']&.first&.dig('text') }&.join(' ')
    end
  end
end
