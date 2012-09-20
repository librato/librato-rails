module Librato
  module Rails
    
    class CounterCache
      extend Forwardable
    
      def_delegators :@cache, :empty?
    
      def initialize
        @cache = {}
        @lock = Mutex.new
      end
    
      def [](key)
        @lock.synchronize { @cache[key.to_s] }
      end
      
      def delete_all
        @lock.synchronize { @cache.clear }
      end
      
      def flush_to(queue)
        counts = nil
        @lock.synchronize do
          counts = @cache.dup
          @cache.clear
        end
        counts.each do |key, value| 
          queue.add key => value
        end
      end
    
      def increment(counter, by=1)
        counter = counter.to_s
        @lock.synchronize do
          @cache[counter] ||= 0
          @cache[counter] += by
        end
      end
    
    end
    
  end
end