module Librato
  module Rails
    module Subscribers
      hooks = %w{enqueue_at enqueue perform_start perform}

      hooks.each do |hook|
        ActiveSupport::Notifications.subscribe "#{hook}.active_job" do |*args|
          collector.group 'rails.job' do |c|
            c.increment hook
          end
        end
      end
    end
  end
end
