module Metrics
  module Rails
    class Railtie < ::Rails::Railtie
      
      # make configuration proxy for config inside Rails
      config.metrics_rails = Metrics::Rails
      
      initializer 'metrics_rails.start_worker' do
        unless ::Rails.env.test?
          Metrics::Rails.start_worker 
        end
      end
      
    end
  end
end  