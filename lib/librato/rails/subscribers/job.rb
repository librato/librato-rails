module Librato
  module Rails
    module Subscribers

      # Active Job

      %w{enqueue_at enqueue perform_start perform}.each do |metric|

        ActiveSupport::Notifications.subscribe "#{metric}.active_job" do |*args|

          event = ActiveSupport::Notifications::Event.new(*args)

          tags = {
            adapter: event.payload[:adapter].class.to_s.demodulize.underscore,
            job: event.payload[:job].class.to_s.demodulize.underscore
          }

          VersionSpecifier.supported(max: '4.2') do
            # Active Support instrumentation payload for :adapter is already a class in Rails 4.2.
            # It was changed to the QueueAdapter object processing the job in Rails 5.
            tags[:adapter] = event.payload[:adapter].to_s.demodulize.underscore
          end

          collector.group "rails.job" do |c|
            c.increment metric, tags: tags, inherit_tags: true
            c.timing "#{metric}.time", event.duration, tags: tags, inherit_tags: true
          end # end group

        end # end subscribe

      end
    end
  end
end
