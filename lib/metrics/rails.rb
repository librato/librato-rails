require 'active_support/notifications'
require 'librato/metrics'

require 'metrics/rails/aggregator'
require 'metrics/rails/counter_cache'
require 'metrics/rails/version'

module Metrics
  module Rails
    extend SingleForwardable
    
    def_delegators :counters, :increment
    def_delegators :aggregate, :timing

    class << self
    
      # access to internal aggregator object
      def aggregate
        @aggregator_cache ||= Aggregator.new
      end
    
      # access to client
      def client
        @client ||= prepare_client
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
      
      # send all current data to Metrics
      def flush
        queue = client.new_queue
        counters.each do |key, value| 
          queue.add "#{metric_prefix}.#{key}" => {:type => :counter, :value => value}
        end
        aggregate.flush_to(queue, :prefix => metric_prefix)
        queue.submit unless queue.empty?
      end
      
      def metric_prefix
        "rails"
      end
      
    private
    
      def prepare_client
        client = Librato::Metrics::Client.new
        client.authenticate 'test@modal.org', 'ff5d710f2b68577d972bbb4c4b97319d6e8a5dabe82c74ee2b964cd9fbc3da83'
        client.api_endpoint = 'http://0.0.0.0:9292'
        client
      end
    
    end # end class << self

  end
end

# must load last
require 'metrics/rails/subscribers'

