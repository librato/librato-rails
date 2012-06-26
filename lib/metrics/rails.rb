require 'active_support/notifications'

require 'metrics/rails/counter_cache'
require 'metrics/rails/version'

module Metrics
  module Rails
    extend SingleForwardable
    
    def_delegators :counters, :increment

    class << self
    
      # access to client
      def client
      end
  
      # access to internal counters object
      def counters
        @counter_cache ||= CounterCache.new
      end
      
      # remove any accumulated but unsent metrics
      def flush
        counters.flush
      end
    
    end # end class << self

  end
end

# must load last
require 'metrics/rails/subscribers'

