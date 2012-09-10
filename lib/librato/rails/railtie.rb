module Librato
  module Rails
    class Railtie < ::Rails::Railtie

      # make configuration proxy for config inside Rails
      config.librato_rails = Librato::Rails

      initializer 'librato_rails.setup' do |app|
        # don't start in test mode or in the console
        unless ::Rails.env.test? || defined?(::Rails::Console)
          Librato::Rails.setup

          app.middleware.use Librato::Rack::Middleware
        end
      end
    end
  end
end
