module Librato
  module Rails
    class Railtie < ::Rails::Railtie

      # don't have any custom http vars anymore, check if hostname is UUID
      on_heroku = Socket.gethostname =~ /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/i

      config.before_configuration do 
        # make configuration proxy for config inside Rails
        config.librato_rails = Configuration.new

        # set up tracker
        tracker = Tracker.new(config.librato_rails)
        config.librato_rails.tracker = tracker
        Librato.register_tracker(tracker)
      end

      initializer 'librato_rails.setup' do |app|

        ActiveSupport.on_load :action_controller do
          extend Librato::Rails::Helpers::Controller
        end

        unless ::Rails.env.test?
          # set up logging; heroku needs logging to STDOUT
          if on_heroku
            logger = Logger.new(STDOUT)
            logger.level = Logger::INFO
          else
            logger = ::Rails.logger
          end
          config.librato_rails.log_target = logger
          config.librato_rails.tracker.log(:debug) { "config: #{config.librato_rails.dump}" }

          if config.librato_rails.tracker.should_start?
            config.librato_rails.tracker.log :info, "starting up (pid #{$$}, using #{config.librato_rails.config_by})..."
            app.middleware.insert(0, Librato::Rack, :config => config.librato_rails)
            config.librato_rails.tracker.check_worker if config.librato_rails.autorun
          end
        end

        tracker = config.librato_rails.tracker
        require_relative 'subscribers/action' if tracker.suite_enabled?(:rails_action)
        require_relative 'subscribers/cache' if tracker.suite_enabled?(:rails_cache)
        require_relative 'subscribers/controller' if tracker.suite_enabled?(:rails_controller)
        require_relative 'subscribers/mail' if tracker.suite_enabled?(:rails_mail)
        require_relative 'subscribers/method' if tracker.suite_enabled?(:rails_method)
        require_relative 'subscribers/render' if tracker.suite_enabled?(:rails_render)
        require_relative 'subscribers/sql' if tracker.suite_enabled?(:rails_sql)
        require_relative 'subscribers/status' if tracker.suite_enabled?(:rails_status)

        Librato::Rails::VersionSpecifier.supported(min: '4.2') do
          require_relative 'subscribers/job'if tracker.suite_enabled?(:rails_job)
        end
      end

    end
  end
end
