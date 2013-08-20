require 'active_support/notifications'

module Librato
  module Rails
    module Subscribers

      # Controllers

      ActiveSupport::Notifications.subscribe /process_action.action_controller/ do |*args|

        event = ActiveSupport::Notifications::Event.new(*args)
        controller = event.payload[:controller]
        action = event.payload[:action]

        format = event.payload[:format] || "all"
        format = "all" if format == "*/*"
        status = event.payload[:status]
        exception = event.payload[:exception]
        # page_key = "request.#{controller}.#{action}_#{format}."

        Librato.group "rails.request" do |r|

          r.increment 'total'
          r.timing    'time', event.duration

          if exception
            r.increment 'exceptions'
          else
            r.timing 'time.db', event.payload[:db_runtime] || 0
            r.timing 'time.view', event.payload[:view_runtime] || 0
          end

          unless status.blank?
            r.group 'status' do |s|
              s.increment status
              s.increment "#{status.to_s[0]}xx"
              s.timing "#{status}.time", event.duration
              s.timing "#{status.to_s[0]}xx.time", event.duration
            end
          end

          r.increment 'slow' if event.duration > 200.0
        end # end group

      end # end subscribe

      # SQL

      ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
        payload = args.last

        Librato.group "rails.sql" do |s|
          # puts (event.payload[:name] || 'nil') + ":" + event.payload[:sql] + "\n"
          s.increment 'queries'

          sql = payload[:sql].strip
          s.increment 'selects' if sql.starts_with?('SELECT')
          s.increment 'inserts' if sql.starts_with?('INSERT')
          s.increment 'updates' if sql.starts_with?('UPDATE')
          s.increment 'deletes' if sql.starts_with?('DELETE')
        end
      end

      # ActionMailer

      ActiveSupport::Notifications.subscribe 'deliver.action_mailer' do |*args|
        # payload[:mailer] => 'UserMailer'
        Librato.increment "rails.mail.sent"
      end

      ActiveSupport::Notifications.subscribe 'receive.action_mailer' do |*args|
        Librato.increment "rails.mail.received"
      end

    end
  end
end