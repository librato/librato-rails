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
        @client ||= prepare_client
      end
  
      # access to internal counters object
      def counters
        @counter_cache ||= CounterCache.new
      end
      
      # remove any accumulated but unsent metrics
      def delete_all
        counters.delete_all
      end
      
    private
    
      def prepare_client
        client = Librato::Metrics::Client.new
        client.authenticate 'matt@librato.com', '02673bee476e872a5c40d4529d98c2cfd2d741882c302c1b7f10ccb1ee9eb45e'
        client
      end
    
    end # end class << self

  end
end

# must load last
require 'metrics/rails/subscribers'

