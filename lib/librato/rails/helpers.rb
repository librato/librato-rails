# Helpers included into controllers and models.

module Librato
  module Rails
    module Helpers
      
      # convenience accessor
      def metrics
        Librato::Rails
      end
      
    end
    
    # ::ActionController::Base.send(:include, Helpers)
    # 
    # ::ActiveRecord::Base.send(:include, Helpers)
    # ::ActiveRecord::Base.send(:extend, Helpers)
  end
end