
# an abstract collector object which can be given measurement values
# and can periodically report those values back to the Metrics service

module Librato
  module Rails
    class Collector
      extend Forwardable
    
      def_delegators :counters, :increment
      def_delegators :aggregate, :measure, :timing
    
      # access to internal aggregator object
      def aggregate
        @aggregator_cache ||= Aggregator.new(:prefix => @prefix)
      end
      
      # access to internal counters object
      def counters
        @counter_cache ||= CounterCache.new
      end
      
      # remove any accumulated but unsent metrics
      def delete_all
        aggregate.delete_all
        counters.delete_all
      end
      
      def group(prefix)
        group = Group.new(prefix)
        yield group
      end
      
      # update prefix
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