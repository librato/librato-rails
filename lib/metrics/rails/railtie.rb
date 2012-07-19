module Metrics
  module Rails
    class Railtie < ::Rails::Railtie
      
      # make configuration proxy for config inside Rails
      config.metrics_rails = Metrics::Rails
      
      initializer 'metrics_rails.setup' do
        unless ::Rails.env.test? || defined?(::Rails::Console)
          Metrics::Rails.setup
        end
      end
      
    end
  end
end  