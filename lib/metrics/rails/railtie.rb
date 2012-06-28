module Metrics
  module Rails
    class Railtie < ::Rails::Railtie
      
      # make configuration proxy for config inside Rails
      config.metrics_rails = Metrics::Rails
      
    end
  end
end  