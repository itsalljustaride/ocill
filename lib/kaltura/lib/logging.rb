require 'logging'

module Logging

  # Option to log to Media specific log or main Rails log
  LOG_MODE = 'main' # main or own

  class << self
    def logger
      if LOG_MODE == 'main'
        @logger ||= Logger.new(STDOUT)
      else
        log_file = "#{Rails.root}/log/kaltura.log"

        if File.exists?(log_file)
          f = File.open(log_file, File::WRONLY | File::APPEND)
        else
          f = File.new(log_file, 'w')
        end

        @logger ||= Logger.new(f)
        @logger.formatter = Logger::Formatter.new
        @logger
      end
    end

    def logger=(logger)
      @logger = logger
    end
  end

  def self.included(base)
    class << base
      def logger
        Logging.logger
      end
    end
  end

  def logger
    Logging.logger
  end

end
