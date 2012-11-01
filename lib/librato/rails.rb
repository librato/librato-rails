require 'socket'
require 'thread'

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'
require 'librato/metrics'

require 'librato/rack'
require 'librato/rails/aggregator'
require 'librato/rails/collector'
require 'librato/rails/counter_cache'
require 'librato/rails/group'
require 'librato/rails/worker'
require 'librato/rails/version'

module Librato
  extend SingleForwardable
  def_delegators Librato::Rails, :increment, :measure, :timing, :group

  module Rails
    extend SingleForwardable
    CONFIG_SETTABLE = %w{user token flush_interval log_level prefix source source_pids}
    FORKING_SERVERS = [:unicorn, :passenger]
    LOG_LEVELS = [:off, :error, :warn, :info, :debug, :trace]

    mattr_accessor :config_file
    self.config_file = 'config/librato.yml'

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

      # set custom api endpoint
      def api_endpoint=(endpoint)
        @api_endpoint = endpoint
      end

      # detect / update configuration
      def check_config
        if self.config_file && File.exists?(self.config_file)
          log :debug, "configuration file present, ignoring ENV variables"
          env_specific = YAML.load(ERB.new(File.read(config_file)).result)[::Rails.env]
          settable = CONFIG_SETTABLE & env_specific.keys
          settable.each { |key| self.send("#{key}=", env_specific[key]) }
        else
          log :debug, "no configuration file present, using ENV variables"
          %w{user token source log_level}.each do |settable|
            env_var = "LIBRATO_METRICS_#{settable.upcase}"
            send("#{settable}=", ENV[env_var]) if ENV[env_var]
          end
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
        log :debug, "flushing #{@pid} (#{Time.now}).."
        start = Time.now
        queue = client.new_queue(:source => qualified_source, :prefix => self.prefix)
        # thread safety is handled internally for both stores
        counters.flush_to(queue)
        aggregate.flush_to(queue)
        trace_queued(queue.queued) if should_log?(:trace)
        queue.submit unless queue.empty?
        log :trace, "flushed #{@pid} in #{(Time.now - start)*1000.to_f}ms"
      rescue Exception => error
        log :error, "submission failed permanently: #{error}"
      end

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
        app.middleware.use Librato::Rack::Middleware
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

      # there isn't anything in the environment before the
      # first request to know if we're running on heroku, but
      # they set all hostnames to UUIDs.
      def implicit_source_on_heroku?
        !explicit_source && on_heroku
      end

      def logger
        @logger ||= if on_heroku
          logger = Logger.new(STDOUT)
          logger.log_level = :info
        else
          ::Rails.logger
        end
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

      def should_log?(level)
        LOG_LEVELS.index(self.log_level) >= LOG_LEVELS.index(level)
      end

      def should_start?
        return false if implicit_source_on_heroku?
        self.user && self.token # are credentials present?
      end

      def source_is_uuid?(source)
        source =~ /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/i
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
