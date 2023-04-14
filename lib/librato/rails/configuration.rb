require "socket"
require "yaml"

module Librato
  module Rails
    # Adds yaml-based config and extra properties to the configuration
    # class provided by librato-rack
    #
    # https://github.com/librato/librato-rack/blob/master/lib/librato/rack/configuration.rb
    #
    class Configuration < Rack::Configuration
      CONFIG_SETTABLE = %w{flush_interval log_level prefix proxy suites tags token user}

      DEFAULT_SUITES = [:rails_cache, :rails_controller, :rails_mail, :rails_method, :rails_render, :rails_sql, :rails_status, :rails_job]

      attr_accessor :config_by, :config_file

      # options:
      # * :config_file - alternate config file location
      #
      def initialize(options={})
        self.config_file = options[:config_file] || 'config/librato.yml'
        super()
        self.log_prefix = '[librato-rails] '
      end

      # detect and load configuration from config file or env vars
      def load_configuration
        if self.config_file && File.exist?(self.config_file)
          configure_with_config_file
        else
          self.config_by = :environment
          super
        end

        self.tags = detect_tags

        # respect autorun and log_level env vars regardless of config method
        self.autorun = detect_autorun
        self.log_level = :info if log_level.blank?
        self.suites = '' if suites.nil?
        self.log_level = ENV['LIBRATO_LOG_LEVEL'] if ENV['LIBRATO_LOG_LEVEL']
      end

      private

      def configure_with_config_file
        self.config_by = :config_file
        env_specific = YAML.load(ERB.new(File.read(config_file)).result)[::Rails.env]
        if env_specific
          settable = CONFIG_SETTABLE & env_specific.keys
          settable.each do |key|
            value = env_specific[key]
            value.symbolize_keys! if key == "tags"
            self.send("#{key}=", value)
          end
        end
      end

      def default_suites
        super + DEFAULT_SUITES
      end

      def default_tags
        {
          service: ::Rails.application.class.to_s.split("::").first.underscore,
          environment: ::Rails.env,
          host: Socket.gethostname.downcase
        }
      end

      def detect_tags
        has_tags? ? default_tags.merge(self.tags) : default_tags
      end

    end
  end
end
