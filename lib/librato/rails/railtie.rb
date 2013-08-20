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

      if !::Rails.env.test? && tracker.should_start?
        unless defined?(::Rails::Console) && ENV['LIBRATO_AUTORUN'] != '1'

          initializer 'librato_rails.setup' do |app|
            # set up logging; heroku needs logs to STDOUT which librato-rack
            # will handle by default
            unless on_heroku
              config.librato_rails.log_target = ::Rails.logger
            end

            tracker.log :info, "starting up..."
            app.middleware.use Librato::Rack, :config => config.librato_rails
          end

        end
      end

    end
  end
end
