module Librato
  module Rails
    module Subscribers

      # Controller Method

      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        http_method = event.payload[:method]

        if http_method
          verb = http_method.to_s.downcase

          collector.group "rails.request.method" do |m|
            m.increment verb
            m.timing "#{verb}.time", event.duration
          end # end group
        end

      end # end subscribe

    end
  end
end
