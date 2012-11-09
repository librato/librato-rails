module Librato
  module Rails
    module Configuration
      CONFIG_SETTABLE = %w{user token flush_interval log_level prefix source source_pids}

      mattr_accessor :config_file
      self.config_file = 'config/librato.yml'

      # set custom api endpoint
      def api_endpoint=(endpoint)
        @api_endpoint = endpoint
      end

      # detect / update configuration
      def check_config
        self.log_level = ENV['LIBRATO_METRICS_LOG_LEVEL'] if ENV['LIBRATO_METRICS_LOG_LEVEL']
        if self.config_file && File.exists?(self.config_file)
          configure_with_config_file
        else
          configure_with_environment
        end
      end

      private

      def configure_with_config_file
        log :debug, "configuring with librato.yml; ignoring environment variables.."
        if env_specific = YAML.load(ERB.new(File.read(config_file)).result)[::Rails.env]
          settable = CONFIG_SETTABLE & env_specific.keys
          settable.each { |key| self.send("#{key}=", env_specific[key]) }
        else
          log :debug, "halting: current environment (#{::Rails.env}) not in config file."
        end
      end

      def configure_with_environment
        log :debug, "using environment variables for configuration.."
        %w{user token source log_level}.each do |settable|
          env_var = "LIBRATO_METRICS_#{settable.upcase}"
          send("#{settable}=", ENV[env_var]) if ENV[env_var]
        end
      end

    end
  end
end