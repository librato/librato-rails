module Metrics
  module Rails
    class Railtie < ::Rails::Railtie

      # make configuration proxy for config inside Rails
      config.metrics_rails = Metrics::Rails

      initializer 'metrics_rails.setup' do |app|
        # don't start in test mode or in the console
        unless ::Rails.env.test? || defined?(::Rails::Console)
          Metrics::Rails.setup

          app.middleware.use Metrics::Rack::Middleware
        end
      end
    end
  end
end
