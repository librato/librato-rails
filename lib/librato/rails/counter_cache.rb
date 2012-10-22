module Librato
  module Rails
    
    class CounterCache
      DEFAULT_SOURCE = '%%'
      
      extend Forwardable
    
      def_delegators :@cache, :empty?
    
      def initialize
        @cache = {}
        @lock = Mutex.new
      end
    
      # Retrieve the current value for a given metric. This is a short
      # form for convenience which only retrieves metrics with no custom
      # source specified. For more options see #fetch.
      #
      # @param [String|Symbol] key metric name
      # @return [Integer|Float] current value
      def [](key)
        @lock.synchronize do 
          @cache[key.to_s][DEFAULT_SOURCE] 
        end
      end
      
      # removes all tracked metrics. note this removes all measurement
      # data AND metric names any continuously tracked metrics will not
      # report until they get another measurement
      def delete_all
        @lock.synchronize { @cache.clear }
      end
      
      
      def fetch(key, options={})
        source = DEFAULT_SOURCE
        if options[:source]
          source = options[:source].to_s
        end
        @lock.synchronize do 
          return nil unless @cache[key.to_s]
          @cache[key.to_s][source]
        end
      end
      
      def flush_to(queue)
        counts = nil
        # work off of a duplicate data set so we block for
        # as little time as possible
        @lock.synchronize do
          counts = @cache.dup
          reset_cache
        end
        counts.each do |key, data|
          data.each do |source, value|
            if source == DEFAULT_SOURCE
              queue.add key => value
            else
              queue.add key => {:value => value, :source => source}
            end
          end
        end
      end
    
      # Increment a given metric
      #
      # @example Increment metric 'foo' by 1
      #   increment :foo
      #
      # @example Increment metric 'bar' by 2
      #   increment :bar, :by => 2
      #
      # @example Increment metric 'foo' by 1 with a custom source
      #   increment :foo, :source => user.id
      #
      def increment(counter, options={})
        if options.is_a?(Fixnum) 
          # suppport legacy style
          options = {:by => options}
        end
        by = options[:by] || 1
        source = DEFAULT_SOURCE
        if options[:source]
          source = options[:source].to_s
        end
        counter = counter.to_s
        @lock.synchronize do
          @cache[counter] ||= {}
          @cache[counter][source] ||= 0
          @cache[counter][source] += by
        end
      end
      
    private
    
      def reset_cache
        @cache.each_key do |key|
          @cache[key].each_key { |source| @cache[key][source] = 0 }
        end
      end
    
    end
    
  end
end