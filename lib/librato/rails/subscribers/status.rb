module Librato
  module Rails
    module Subscribers

      # Controller Status

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        status = event.payload[:status]

        unless status.blank?
          collector.group "rails.request.status" do |s|
            s.increment status
            s.increment "#{status.to_s[0]}xx"
            s.timing "#{status}.time", event.duration
            s.timing "#{status.to_s[0]}xx.time", event.duration
          end # end group
        end

      end # end subscribe

    end
  end
end
