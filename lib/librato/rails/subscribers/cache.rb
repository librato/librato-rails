module Librato
  module Rails
    module Subscribers

      # Cache

      %w{read generate fetch_hit write delete}.each do |metric|

        ActiveSupport::Notifications.subscribe "cache_#{metric}.active_support" do |*args|

          event = ActiveSupport::Notifications::Event.new(*args)

          collector.group "rails.cache" do |c|
            c.increment metric
            c.timing "#{metric}.time", event.duration
          end # end group

        end # end subscribe

      end

    end
  end
end
