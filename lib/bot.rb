# frozen_string_literal: true

require 'dotenv/load'
require 'logger'
require 'telegram/bot'

require_relative 'file_process'
require_relative 'logger_process'
require_relative 'recognition_process'

class Bot
  def self.call
    Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
      LoggerProcess.call('Bot is running')
      bot.listen do |message|
        bot.logger

        if message.voice
          FileProcess.call(message, ENV['TELEGRAM_TOKEN'])
          text = RecognitionProcess.call || 'Текст не распознан отправьте еще раз'
          LoggerProcess.call(text)

          bot.api.send_message(chat_id: message.chat.id, text: text)
        else
          LoggerProcess.call(message)

          bot.api.send_message(chat_id: message.chat.id, text: 'Отправьте голосовое сообщение')
        end
      rescue Telegram::Bot::Exceptions::ResponseError => e
        LoggerProcess.call(e)
        retry
      end
    end
  end
end
