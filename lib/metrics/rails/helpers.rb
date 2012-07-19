# Helpers included into controllers and models.

module Metrics
  module Rails
    module Helpers
      
      # convenience accessor
      def metrics
        Metrics::Rails
      end
      
    end

    ActionController::Base.send(:include, Helpers)
    # ActiveRecord::Base.include Helpers
  end
end