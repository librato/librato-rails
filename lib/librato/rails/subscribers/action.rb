module Librato
  module Rails
    module Subscribers

      # Controller Actions

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        controller = event.payload[:controller]
        action = event.payload[:action]

        format = event.payload[:format] || "all"
        format = "all" if format == "*/*"
        exception = event.payload[:exception]

        if @watches && (@watches.index(controller) || @watches.index("#{controller}##{action}"))
          source = "#{controller}.#{action}.#{format}"
          collector.group 'rails.action.request' do |r|

            r.increment 'total', source: source
            r.increment 'slow', source: source if event.duration > 200.0
            r.timing    'time', event.duration, source: source, percentile: 95

            if exception
              r.increment 'exceptions', source: source
            else
              r.timing 'time.db', event.payload[:db_runtime] || 0, source: source, percentile: 95
              r.timing 'time.view', event.payload[:view_runtime] || 0, source: source, percentile: 95
            end

          end
        end

      end # end subscribe

    end
  end
end
