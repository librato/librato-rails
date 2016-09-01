module Librato
  module Rails
    module Subscribers

      # ActionController Status

      ActiveSupport::Notifications.subscribe "process_action.action_controller" do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        tags = {
          status: event.payload[:status],
          status_message: ::Rack::Utils::HTTP_STATUS_CODES[event.payload[:status]]
        }

        unless tags[:status].blank?
          collector.group "rails.request" do |s|
            s.increment "status", tags: tags
            s.timing "status.time", event.duration, tags: tags
          end # end group
        end

      end # end subscribe

    end
  end
end
