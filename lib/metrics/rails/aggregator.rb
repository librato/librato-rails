module Metrics
  module Rails
    class Aggregator
      #extend Forwardable
      
      def initialize
        @cache = Librato::Metrics::Aggregator.new
      end
      
      def [](key)
        return nil if @cache.empty?
        require 'pry'
        @cache.queued[:gauges].each do |metric|
          return metric if metric[:name] == key.to_s
        end
        nil
      end
      
      def delete_all
        @cache.clear
      end
      
      # transfer all measurements to a queue and 
      # reset internal status
      def flush_to(queue, options={})
        return if @cache.empty?
        queue.queued[:gauges] ||= []
        q = @cache.queued[:gauges]
        if options[:prefix]
          q.map! { |m| m[:name] = "#{options[:prefix]}.#{m[:name]}"; m }
        end
        queue.queued[:gauges] += q
      end
      
      def timing(event, duration)
        @cache.add event.to_s => duration
      end
      
    end
  end
end