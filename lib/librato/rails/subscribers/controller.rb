module Librato
  module Rails
    module Subscribers

      # Controllers

      def self.watch_controller(controller)
        @watches ||= []
        @watches << "#{controller}".freeze
      end

      def self.watch_controller_action(controller, action)
        @watches ||= []
        @watches << "#{controller}##{action}".freeze
      end

      AS = ActiveSupport
      AS::Notifications.subscribe 'process_action.action_controller' do |*args|

        event = AS::Notifications::Event.new(*args)
        controller = event.payload[:controller]
        action = event.payload[:action]

        format = event.payload[:format] || "all"
        format = "all" if format == "*/*"
        status = event.payload[:status]
        http_method = event.payload[:method]
        exception = event.payload[:exception]
        # page_key = "request.#{controller}.#{action}_#{format}."

        collector.group "rails.request" do |r|

          r.increment 'total'
          r.timing    'time', event.duration

          if exception
            r.increment 'exceptions'
          else
            r.timing 'time.db', event.payload[:db_runtime] || 0
            r.timing 'time.view', event.payload[:view_runtime] || 0
          end

          if http_method
            verb = http_method.to_s.downcase
            r.group 'method' do |m|
              m.increment verb
              m.timing "#{verb}.time", event.duration
            end
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

        if @watches && (@watches.index("#{controller}##{action}") || @watches.index("#{controller}"))
          source = "#{controller}.#{action}.#{format}"
          collector.group 'rails.action.request' do |r|

            r.increment 'total', source: source
            r.increment 'slow', source: source if event.duration > 200.0
            r.timing    'time', event.duration, source: source

            if exception
              r.increment 'exceptions', source: source
            else
              r.timing 'time.db', event.payload[:db_runtime] || 0, source: source
              r.timing 'time.view', event.payload[:view_runtime] || 0, source: source
            end

          end
        end

      end # end subscribe

    end
  end
end