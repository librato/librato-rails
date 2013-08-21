module Librato
  module Rails
    class Railtie < ::Rails::Railtie

      # don't have any custom http vars anymore, check if hostname is UUID
      on_heroku = Socket.gethostname =~ /[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}/i

      # make configuration proxy for config inside Rails
      config.librato_rails = Configuration.new

      # set up tracker
      tracker = Tracker.new(config.librato_rails)
      config.librato_rails.tracker = tracker
      Librato.register_tracker(tracker)

      unless ::Rails.env.test?
        unless defined?(::Rails::Console) && ENV['LIBRATO_AUTORUN'] != '1'

          initializer 'librato_rails.setup' do |app|
            # set up logging; heroku needs logging to STDOUT
            if on_heroku
              logger = Logger.new(STDOUT)
              logger.level = Logger::INFO
            else
              logger = ::Rails.logger
            end
            config.librato_rails.log_target = logger
            tracker.log(:debug) { "config: #{config.librato_rails.dump}" }

            if tracker.should_start?
              tracker.log :info, "starting up (pid #{$$}, using #{config.librato_rails.config_by})..."
              app.middleware.use Librato::Rack, :config => config.librato_rails
            end
          end

        end
      end

    end
  end
end
