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
      end
  
      # access to internal counters object
      def counters
        @counter_cache ||= CounterCache.new
      end
      
      # remove any accumulated but unsent metrics
      def flush
        counters.flush
      end
    
    end

    ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  
      event = ActiveSupport::Notifications::Event.new(*args)
      controller = event.payload[:controller]
      action = event.payload[:action]
  
      format = event.payload[:format] || "all"
      format = "all" if format == "*/*"
      status = event.payload[:status]
      exception = event.payload[:exception]
  
      # key = 'request'
      page_key = "request.#{controller}.#{action}_#{format}."
  
      increment "request.total"
    end

  end
end


