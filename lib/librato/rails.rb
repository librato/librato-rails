require 'socket'
require 'thread'

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'
require 'librato/metrics'

require 'librato/rack'
require 'librato/rails/aggregator'
require 'librato/rails/collector'
require 'librato/rails/configuration'
require 'librato/rails/counter_cache'
require 'librato/rails/group'
require 'librato/rails/logging'
require 'librato/rails/validating_queue'
require 'librato/rails/version'
require 'librato/rails/worker'

module Librato
  extend SingleForwardable
  def_delegators Librato::Rails, :increment, :measure, :timing, :group

  module Rails
    extend SingleForwardable
    extend Librato::Rails::Configuration
    extend Librato::Rails::Logging

    FORKING_SERVERS = [:unicorn, :passenger]
    SOURCE_REGEX = /\A[-:A-Za-z0-9_.]{1,255}\z/

    # config options
    mattr_accessor :user
    mattr_accessor :token
    mattr_accessor :flush_interval
    mattr_accessor :source_pids

    # config defaults
    self.flush_interval = 60 # seconds
    self.source_pids = false # append process id to the source?
    # log_level (default :info)
    # source (default: your machine's hostname)

    # handy introspection
    mattr_accessor :explicit_source

    # a collector instance handles all measurement addition/storage
    def_delegators :collector, :aggregate, :counters, :delete_all, :group, :increment,
                               :measure, :prefix, :prefix=, :timing

    class << self

      # check to see if we've forked into a process where a worker
      # isn't running yet, if so start it up!
      def check_worker
        if @pid != $$
          start_worker
          # aggregate.clear
          # counters.clear
        end
      end

      # access to client instance
      def client
        @client ||= prepare_client
      end

      # collector instance which is tracking all measurement additions
      def collector
        @collector ||= Collector.new
      end

      # send all current data to Metrics
      def flush
        log :debug, "flushing pid #{@pid} (#{Time.now}).."
        start = Time.now
        queue = flush_queue
        # thread safety is handled internally for both stores
        counters.flush_to(queue)
        aggregate.flush_to(queue)
        trace_queued(queue.queued) if should_log?(:trace)
        queue.submit unless queue.empty?
        log :trace, "flushed pid #{@pid} in #{(Time.now - start)*1000.to_f}ms"
      rescue Exception => error
        log :error, "submission failed permanently: #{error}"
      end

      # source including process pid
      def qualified_source
        self.source_pids ? "#{source}.#{$$}" : source
      end

      # run once during Rails startup sequence
      def setup(app)
        check_config
        trace_settings if should_log?(:debug)
        return unless should_start?
        if app_server == :other
          log :info, "starting up..."
        else
          log :info, "starting up with #{app_server}..."
        end
        @pid = $$
        app.middleware.insert(0, Librato::Rack::Middleware)
        start_worker unless forking_server?
      end

      def source
        return @source if @source
        self.explicit_source = false
        @source = Socket.gethostname
      end

      # set a custom source
      def source=(src)
        self.explicit_source = true
        @source = src
      end

      # start the worker thread, one is needed per process.
      # if this process has been forked from an one with an active
      # worker thread we don't need to worry about cleanup as only
      # the forking thread is copied.
      def start_worker
        return if @worker # already running
        @pid = $$
        log :debug, ">> starting up worker for pid #{@pid}..."
        @worker = Thread.new do
          worker = Worker.new
          worker.run_periodically(self.flush_interval) do
            flush
          end
        end
      end

    private

      def app_server
        if defined?(::Unicorn) && defined?(::Unicorn::HttpServer) && !::Unicorn.listener_names.empty?
          :unicorn
        elsif defined?(::IN_PHUSION_PASSENGER) || defined?(::PhusionPassenger)
          :passenger
        elsif defined?(::Thin) && defined?(::Thin::Server)
          :thin
        else
          :other
        end
      end

      def flush_queue
        ValidatingQueue.new(
          :client => client,
          :source => qualified_source,
          :prefix => self.prefix,
          :skip_measurement_times => true )
      end

      def forking_server?
        FORKING_SERVERS.include?(app_server)
      end

      def on_heroku
        # would be nice to have something more specific here,
        # but nothing characteristic in ENV, etc.
        @on_heroku ||= source_is_uuid?(Socket.gethostname)
      end

      def prepare_client
        check_config
        client = Librato::Metrics::Client.new
        client.authenticate user, token
        client.api_endpoint = @api_endpoint if @api_endpoint
        client.custom_user_agent = user_agent
        client
      end

      def ruby_engine
        return RUBY_ENGINE if Object.constants.include?(:RUBY_ENGINE)
        RUBY_DESCRIPTION.split[0]
      end

      def should_start?
        if !self.user || !self.token
          # don't show this unless we're debugging, expected behavior
          log :debug, 'halting: credentials not present.'
          false
        elsif qualified_source !~ SOURCE_REGEX
          log :warn, "halting: '#{qualified_source}' is an invalid source name."
          false
        elsif !explicit_source && on_heroku
          log :warn, 'halting: source must be provided in configuration.'
          false
        else
          true
        end
      end

      def source_is_uuid?(source)
        source =~ /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/i
      end

      def user_agent
        ua_chunks = []
        ua_chunks << "librato-rails/#{Librato::Rails::VERSION}"
        ua_chunks << "(#{ruby_engine}; #{RUBY_VERSION}p#{RUBY_PATCHLEVEL}; #{RUBY_PLATFORM}; #{app_server})"
        ua_chunks.join(' ')
      end

    end # end class << self

  end
end

# must load after all module setup
require 'librato/rails/railtie' if defined?(Rails)
require 'librato/rails/subscribers'
