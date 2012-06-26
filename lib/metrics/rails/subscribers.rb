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
  
      # key = 'request'
      # page_key = "request.#{controller}.#{action}_#{format}."
  
      increment 'request.total'
      
      unless status.blank?
        increment "request.status.#{status}"
        increment "request.status.#{status.to_s[0]}xx"
      end
      
      if exception
        increment 'request.exceptions'
      end
      
      if event.duration > 200.0
        increment 'request.slow'
      end
      
    end
  
  end
end