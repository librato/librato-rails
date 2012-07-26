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
  
      group "#{Metrics::Rails.prefix}.request" do |r|
   
        r.increment 'total'
        r.timing    'time', event.duration
      
        if exception
          r.increment 'exceptions'
        else
          r.timing 'time.db', event.payload[:db_runtime]
          r.timing 'time.view', event.payload[:view_runtime]
        end
      
        unless status.blank?
          r.group 'status' do |s|
            s.increment status
            s.increment "#{status.to_s[0]}xx"
            s.timing "#{status}.time", event.duration
            s.timing "#{status.to_s[0]}xx.time", event.duration
          end
        end
      
        r.increment 'slow' if event.duration > 200.0
      end # end group
      
    end # end subscribe
  
    # SQL
    
    ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
      event = ActiveSupport::Notifications::Event.new(*args)
  
      group "#{Metrics::Rails.prefix}.sql" do |r|
        # puts (event.payload[:name] || 'nil') + ":" + event.payload[:sql] + "\n"
        r.increment 'queries'
        
        sql = event.payload[:sql].strip
        r.increment 'selects' if sql.starts_with?('SELECT')
        r.increment 'inserts' if sql.starts_with?('INSERT')
        # r.increment 'selects' if sql.starts_with?('SELECT')
        #         r.increment 'selects' if sql.starts_with?('SELECT')
      end
    end
  
  end
end