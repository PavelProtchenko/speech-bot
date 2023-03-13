# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv/load'
require 'logger'

require_relative 'file_process'
require_relative 'recognition_process'

class Bot
  def self.call
    Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN'], logger: Logger.new($stderr)) do |bot|
      bot.listen do |message|
        bot.logger

        if message.voice
          FileProcess.call(message, ENV['TELEGRAM_TOKEN'])
          text = RecognitionProcess.call || 'Текст не распознан отправьте еще раз'

          bot.api.send_message(chat_id: message.chat.id, text: text)
        else
          bot.api.send_message(chat_id: message.chat.id, text: 'Отправьте голосовое сообщение')
        end
      rescue Telegram::Bot::Exceptions::ResponseError => e
        bot.logger e
        retry
      end
    end
  end
end
