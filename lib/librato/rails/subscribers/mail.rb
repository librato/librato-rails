module Librato
  module Rails
    module Subscribers

      # ActionMailer

      ActiveSupport::Notifications.subscribe "deliver.action_mailer" do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        tags = { mailer: event.payload[:mailer] }
        collector.increment "rails.mail.sent", tags: tags
      end # end subscribe

      ActiveSupport::Notifications.subscribe "receive.action_mailer" do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        tags = { mailer: event.payload[:mailer] }
        collector.increment "rails.mail.received", tags: tags
      end # end subscribe

    end
  end
end
