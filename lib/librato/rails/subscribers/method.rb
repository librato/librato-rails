module Librato
  module Rails
    module Subscribers

      # ActionController Method

      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        tags = { method: event.payload[:method].to_s.downcase }

        if tags[:method]
          collector.group "rails.request" do |m|
            m.increment "method", tags: tags
            m.timing "method.time", event.duration, tags: tags
          end # end group
        end

      end # end subscribe

    end
  end
end
