require 'socket'
require 'thread'

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'
require 'librato/metrics'

require 'librato/rack'
require 'librato/rails/aggregator'
require 'librato/rails/counter_cache'
require 'librato/rails/group'
require 'librato/rails/helpers'
require 'librato/rails/worker'
require 'librato/rails/version'

module Librato
  extend SingleForwardable
  def_delegators Librato::Rails, :increment, :measure, :timing, :group

  module Rails
    extend SingleForwardable
    CONFIG_SETTABLE = %w{user token flush_interval prefix source}
    FORKING_SERVERS = [:unicorn, :passenger]

    mattr_accessor :config_file
    self.config_file = 'config/librato.yml'

    # config options
    mattr_accessor :user
    mattr_accessor :token
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
          logger.debug "[librato-rails] configuration file present, ignoring ENV variables"
          configs = YAML.load_file(config_file)
          if env_specific = configs[::Rails.env]
            settable = CONFIG_SETTABLE & env_specific.keys
            settable.each { |key| self.send("#{key}=", env_specific[key]) }
          end
        else
          logger.debug "[librato-rails] no configuration file present, using ENV variables"
          self.token = ENV['LIBRATO_METRICS_TOKEN'] if ENV['LIBRATO_METRICS_TOKEN']
          self.user = ENV['LIBRATO_METRICS_USER'] if ENV['LIBRATO_METRICS_USER']
          self.token = ENV['LIBRATO_METRICS_SOURCE'] if ENV['LIBRATO_METRICS_SOURCE']
        end
      end

      # check to see if we've forked into a process where a worker
      # isn't running yet, if so start it up!
      def check_worker
        if @pid != $$
          start_worker
          # aggregate.clear
          # counters.clear
        end
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
        logger.debug "[librato-rails] flushing #{Process.pid} (#{Time.now}):"
        queue = client.new_queue(:source => qualified_source)
        # thread safety is handled internally for both stores
        counters.flush_to(queue)
        aggregate.flush_to(queue)
        logger.debug queue.queued
        queue.submit unless queue.empty?
      rescue Exception => error
        logger.error "[librato-rails] submission failed permanently, worker exiting: #{error}"
      end

      def group(prefix)
        group = Group.new(prefix)
        yield group
      end

      def logger
        @logger ||= ::Rails.logger
      end

      # source including process pid
      def qualified_source
        "#{source}.#{$$}"
      end

      # run once during Rails startup sequence
      def setup
        check_config
        # return unless self.email && self.api_key
        logger.info "[librato-rails] starting up with #{app_server}..."
        @pid = $$
        if forking_server?
          install_worker_check
        else
          start_worker # start immediately
        end
      end

      def source
        @source ||= Socket.gethostname
      end

      # set a custom source
      def source=(src)
        @source = src
      end

      # start the worker thread, one is needed per process.
      # if this process has been forked from an one with an active
      # worker thread we don't need to worry about cleanup as only
      # the forking thread is copied.
      def start_worker
        return if @worker # already running
        @pid = $$
        logger.debug "[librato-rails] >> starting up worker for pid #{@pid}..."
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
        elsif defined?(::IN_PHUSION_PASSENGER) || (defined?(::Passenger) && defined?(::Passenger::AbstractServer))
          :passenger
        elsif defined?(::Thin) && defined?(::Thin::Server)
          :thin
        else
          :other
        end
      end

      def forking_server?
        FORKING_SERVERS.include?(app_server)
      end

      def install_worker_check
        ::ApplicationController.prepend_before_filter do |c|
          Librato::Rails.check_worker
        end
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
