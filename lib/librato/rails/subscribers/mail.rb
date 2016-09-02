module Librato
  module Rails
    module Subscribers

      # ActionMailer

      %w{sent received}.each do |metric|

        ActiveSupport::Notifications.subscribe "deliver.action_mailer" do |*args|

          event = ActiveSupport::Notifications::Event.new(*args)
          tags = { mailer: event.payload[:mailer] }

          collector.increment "rails.mail.#{metric}", tags: tags

        end # end subscribe

      end

    end
  end
end
