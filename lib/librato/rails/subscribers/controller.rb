module Librato
  module Rails
    module Subscribers

      # ActionController

      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        exception = event.payload[:exception]
        format = event.payload[:format].to_s || "all"
        format = "all" if format == "*/*"
        tags = {
          controller: event.payload[:controller],
          action: event.payload[:action],
          format: format,
        }

        collector.group "rails.request" do |r|
          r.increment "total", tags: tags, inherit_tags: true
          r.timing    "time", event.duration, tags: tags, inherit_tags: true, percentile: 95
          r.timing "time.db", event.payload[:db_runtime] || 0, tags: tags, inherit_tags: true, percentile: 95
          r.timing "time.view", event.payload[:view_runtime] || 0, tags: tags, inherit_tags: true, percentile: 95

          if event.duration > 200.0
            r.increment "slow", tags: tags, inherit_tags: true
          end
        end # end group

      end # end subscribe

    end
  end
end
