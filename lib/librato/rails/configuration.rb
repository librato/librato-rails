module Librato
  module Rails
    module Configuration
      CONFIG_SETTABLE = %w{user token flush_interval log_level prefix source source_pids use_middleware use_subscribers}

      mattr_accessor :config_file
      self.config_file = 'config/librato.yml'

      # set custom api endpoint
      def api_endpoint=(endpoint)
        @api_endpoint = endpoint
      end

      # detect / update configuration
      def check_config
        self.log_level = ENV['LIBRATO_LOG_LEVEL'] if ENV['LIBRATO_LOG_LEVEL']
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
        %w{user token source log_level prefix}.each do |settable|
          legacy_env_var = "LIBRATO_METRICS_#{settable.upcase}"
          if ENV[legacy_env_var]
            log :warn, "#{legacy_env_var} is deprecated, use LIBRATO_#{settable.upcase} instead"
            send("#{settable}=", ENV[legacy_env_var])
          end
          # if both are present, new-style dominates
          env_var = "LIBRATO_#{settable.upcase}"
          send("#{settable}=", ENV[env_var]) if ENV[env_var]
        end
      end

    end
  end
end
