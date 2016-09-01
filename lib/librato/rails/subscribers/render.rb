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
            tags = { view: metric, identifier: identifier }
            collector.group "rails.view" do |c|
              c.increment "render", tags: tags, sporadic: true
              c.timing "render.time", event.duration, tags: tags, sporadic: true
            end # end group
          end

        end # end subscribe

      end

    end
  end
end
