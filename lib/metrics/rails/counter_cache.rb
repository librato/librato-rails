module Metrics
  module Rails
    
    class CounterCache
      extend Forwardable
    
      def_delegators :@cache, :each
    
      def initialize
        @cache = {}
      end
    
      def [](key)
        @cache[key.to_s]
      end
      
      def delete_all
        @cache = {}
      end
    
      def increment(counter, by=1)
        counter = counter.to_s
        @cache[counter] ||= 0
        @cache[counter] += by
      end
    
    end
    
  end
end