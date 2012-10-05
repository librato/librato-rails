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

      def measure(*args, &block)
        event = args[0].to_s
        returned = nil
        if block_given?
          start = Time.now
          returned = yield
          value = ((Time.now - start) * 1000.0).to_i
        elsif args[1]
          value = args[1]
        else
          raise "no value provided"
        end
        @lock.synchronize do
          @cache.add event => value
        end
        returned
      end
      alias :timing :measure

    end
  end
end