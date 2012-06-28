module Metrics
  module Rails
  
    # controllers
    
    ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|
  
      event = ActiveSupport::Notifications::Event.new(*args)
      controller = event.payload[:controller]
      action = event.payload[:action]
  
      format = event.payload[:format] || "all"
      format = "all" if format == "*/*"
      status = event.payload[:status]
      exception = event.payload[:exception]
      # page_key = "request.#{controller}.#{action}_#{format}."
  
      increment 'request.total'
      timing    'request.time.total', event.duration
      
      if exception
        increment 'request.exceptions'
      else
        timing 'request.time.db', event.payload[:db_runtime]
        timing 'request.time.view', event.payload[:view_runtime]
      end
      
      unless status.blank?
        increment "request.status.#{status}"
        increment "request.status.#{status.to_s[0]}xx"
        timing "request.status.#{status}.time.total", event.duration
        timing "request.status.#{status.to_s[0]}xx.time.total", event.duration
      end
      
      if event.duration > 200.0
        increment 'request.slow'
      end
      
    end
  
  end
end