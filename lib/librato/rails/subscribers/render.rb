module Librato
  module Rails
    module Subscribers

      # Render operations

      %w{partial template}.each do |metric|

        ActiveSupport::Notifications.subscribe "render_#{metric}.action_view" do |*args|

          event = ActiveSupport::Notifications::Event.new(*args)
          path = event.payload[:identifier].split('/views/', 2)

          if path[1]
            identifier = path[1].gsub('/', ':')
            # trim leading underscore for partials
            identifier.gsub!(':_', ':') if metric == "partial"
            collector.group "rails.view" do |c|
              c.increment "render_#{metric}", tags: { identifier: identifier }, sporadic: true
              c.timing "render_#{metric}.time", event.duration, tags: { identifier: identifier }, sporadic: true
            end # end group
          end

        end # end subscribe

      end

    end
  end
end
