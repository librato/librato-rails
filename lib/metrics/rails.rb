require 'thread'

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'
require 'librato/metrics'

require 'metrics/rails/aggregator'
require 'metrics/rails/counter_cache'
require 'metrics/rails/worker'
require 'metrics/rails/version'

module Metrics
  module Rails
    extend SingleForwardable
    CONFIG_SETTABLE = %w{api_key email flush_interval prefix source}
    
    mattr_accessor :config_file
    
    # config options
    mattr_accessor :api_key
    mattr_accessor :email
    mattr_accessor :flush_interval
    mattr_accessor :prefix
    
    # config defaults
    self.flush_interval = 60 # seconds
    self.prefix = 'rails'
    
    def_delegators :counters, :increment
    def_delegators :aggregate, :measure, :timing

    class << self
    
      # access to internal aggregator object
      def aggregate
        @aggregator_cache ||= Aggregator.new
      end
      
      # set custom api endpoint
      def api_endpoint=(endpoint)
        @api_endpoint = endpoint
      end
    
      # access to client instance
      def client
        @client ||= prepare_client
      end
      
      # detect / update configuration
      def check_config
        if self.config_file && File.exists?(self.config_file)
          configs = YAML.load_file(config_file)
          if env_specific = configs[::Rails.env]
            settable = CONFIG_SETTABLE & env_specific.keys
            settable.each { |key| self.send("#{key}=", env_specific[key]) }
          end
        end
        self.api_key = ENV['METRICS_API_KEY'] if ENV['METRICS_API_KEY']
        self.email = ENV['METRICS_EMAIL'] if ENV['METRICS_EMAIL']
      end
  
      # access to internal counters object
      def counters
        @counter_cache ||= CounterCache.new
      end
      
      # remove any accumulated but unsent metrics
      def delete_all
        aggregate.delete_all
        counters.delete_all
      end
      
      # send all current data to Metrics
      def flush
        logger.info ' >> flushing at ' + Time.now.to_s
        queue = client.new_queue
        # thread safety is handled internally for both stores
        counters.flush_to(queue)
        aggregate.flush_to(queue)
        queue.submit unless queue.empty?
      end
      
      def logger
        @logger ||= ::Rails.logger
      end
      
      # source including process pid
      def qualified_source
        "#{source}.#{Process.pid}"
      end
      
      def source
        @source ||= Socket.gethostname
      end
      
      # set a custom source
      def source=(src)
        @source = src
      end
      
      def start_worker
        logger.info '[metrics-rails] starting up worker...'
        Thread.new do
          worker = Worker.new
          worker.run_periodically(self.flush_interval) do
            flush
          end
        end
      end
      
    private
    
      def prepare_client
        check_config
        client = Librato::Metrics::Client.new
        client.authenticate email, api_key
        client.api_endpoint = @api_endpoint if @api_endpoint
        client
      end
    
    end # end class << self

  end
end

# must load after all module setup
require 'metrics/rails/railtie'
require 'metrics/rails/subscribers'
