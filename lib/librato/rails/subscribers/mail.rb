module Librato
  module Rails
    module Subscribers

      # ActionMailer

      ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
        # payload[:mailer] => 'UserMailer'
        collector.increment "rails.mail.sent"
      end

      ActiveSupport::Notifications.subscribe 'receive.action_mailer' do |*args|
        collector.increment "rails.mail.received"
      end

    end
  end
end