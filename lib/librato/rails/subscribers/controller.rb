module Librato
  module Rails
    module Subscribers

      # Controllers

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        exception = event.payload[:exception]

        collector.group "rails.request" do |r|

          r.increment 'total'
          r.timing    'time', event.duration, percentile: 95

          if exception
            r.increment 'exceptions'
          else
            r.timing 'time.db', event.payload[:db_runtime] || 0, percentile: 95
            r.timing 'time.view', event.payload[:view_runtime] || 0, percentile: 95
          end

          r.increment 'slow' if event.duration > 200.0
        end # end group

      end # end subscribe

    end
  end
end
