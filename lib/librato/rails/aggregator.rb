module Librato
  module Rails
    class Aggregator
      extend Forwardable
      
      def_delegators :@cache, :empty?
      
      def initialize
        @cache = Librato::Metrics::Aggregator.new
        @lock = Mutex.new
      end
      
      def [](key)
        return nil if @cache.empty?
        gauges = nil
        @lock.synchronize { gauges = @cache.queued[:gauges] }
        gauges.each do |metric|
          return metric if metric[:name] == key.to_s
        end
        nil
      end
      
      def delete_all
        @lock.synchronize { @cache.clear }
      end
      
      # transfer all measurements to a queue and 
      # reset internal status
      def flush_to(queue, options={})
        queued = nil
        @lock.synchronize do
          return if @cache.empty?
          queued = @cache.queued
          @cache.clear
        end
        queue.merge!(queued) if queued
      end
      
      def measure(event, duration)
        @lock.synchronize do
          @cache.add event.to_s => duration
        end
      end
      alias :timing :measure
      
    end
  end
end