module Librato
  module Rails
    class Railtie < ::Rails::Railtie

      # make configuration proxy for config inside Rails
      config.librato_rails = Configuration.new
      tracker = Tracker.new(config.librato_rails)
      config.librato_rails.tracker = tracker

      if !::Rails.env.test? && tracker.should_start?
        unless defined?(::Rails::Console) && ENV['LIBRATO_AUTORUN'] != '1'

          initializer 'librato_rails.setup' do |app|
            tracker.log :info, "starting up..."
            app.middleware.use Librato::Rack, :config => config.librato_rails
          end

        end
      end

    end
  end
end
