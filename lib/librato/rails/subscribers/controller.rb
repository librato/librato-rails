module Librato
  module Rails
    module Subscribers

      # ActionController

      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        exception = event.payload[:exception]
        tags = {
          controller: event.payload[:controller],
          action: event.payload[:action],
          format: event.payload[:format].to_s,
        }

        collector.group "rails.request" do |r|
          r.increment "total", tags: tags
          r.timing    "time", event.duration, tags: tags, percentile: 95
          r.timing "time.db", event.payload[:db_runtime] || 0, tags: tags, percentile: 95
          r.timing "time.view", event.payload[:view_runtime] || 0, tags: tags, percentile: 95

          if event.duration > 200.0
            r.increment "slow", tags: tags
          end
        end # end group

      end # end subscribe

    end
  end
end
