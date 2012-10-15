
# an abstract collector object which can be given measurement values
# and can periodically report those values back to the Metrics service

module Librato
  module Rails
    class Collector
      extend Forwardable
    
      # access to internal aggregator object
      def aggregate
        @aggregator_cache ||= Aggregator.new(:prefix => @prefix)
      end
      
      def prefix=(new_prefix)
        @prefix = new_prefix
        aggregate.prefix = @prefix
      end
      
      def prefix
        @prefix
      end
    end
  end
end