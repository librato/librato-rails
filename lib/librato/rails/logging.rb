module Librato::Rails
  module Logging
    LOG_LEVELS = [:off, :error, :warn, :info, :debug, :trace]

    # ex: log :debug, 'this is a debug message'
    def log(level, message)
      return unless should_log?(level)
      case level
      when :error, :warn
        method = level
      else
        method = :info
      end
      message = '[librato-rails] ' << message
      logger.send(method, message)
    end

    # set log level to any of LOG_LEVELS
    def log_level=(level)
      level = level.to_sym
      if LOG_LEVELS.index(level)
        @log_level = level
        require 'pp' if should_log?(:debug)
      else
        raise "Invalid log level '#{level}'"
      end
    end

    def log_level
      @log_level ||= :info
    end

    def logger
      @logger ||= if on_heroku
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        logger
      else
        ::Rails.logger
      end
    end

    attr_writer :logger

    private

    def should_log?(level)
      LOG_LEVELS.index(self.log_level) >= LOG_LEVELS.index(level)
    end

    # trace current environment
    def trace_environment
      log :info, "Environment: " + ENV.pretty_inspect
    end

    # trace metrics being sent
    def trace_queued(queued)
      log :trace, "Queued: " + queued.pretty_inspect
    end

    def trace_settings
      settings = {
        :user => self.user,
        :token => self.token,
        :source => source,
        :explicit_source => self.explicit_source ? 'true' : 'false',
        :source_pids => self.source_pids ? 'true' : 'false',
        :qualified_source => qualified_source,
        :log_level => log_level,
        :prefix => prefix,
        :flush_interval => self.flush_interval
      }
      log :info, 'Settings: ' + settings.pretty_inspect
    end

  end
end
