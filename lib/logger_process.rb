# frozen_string_literal: true

require 'logger'

class LoggerProcess
  def self.call(message = 'Insert message')
    logger = Logger.new($stdout)
    logger.info(message: message)
  end
end
