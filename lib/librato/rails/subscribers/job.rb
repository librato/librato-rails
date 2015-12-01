module Librato
  module Rails
    module Subscribers
      hooks = %w{enqueue_at enqueue perform_start perform}

      hooks.each do |hook|
        ActiveSupport::Notifications.subscribe "#{hook}.active_job" do |*args|
          event = ActiveSupport::Notifications::Event.new(*args)

          collector.group 'rails.job' do |c|
            c.increment hook
            c.timing "#{hook}.time", event.duration, source: event.payload[:job].class
          end
        end
      end
    end
  end
end
