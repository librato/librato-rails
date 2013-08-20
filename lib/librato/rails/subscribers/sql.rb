module Librato
  module Rails
    module Subscribers

      # SQL

      ActiveSupport::Notifications.subscribe 'sql.active_record' do |*args|
        payload = args.last

        collector.group "rails.sql" do |s|
          # puts (event.payload[:name] || 'nil') + ":" + event.payload[:sql] + "\n"
          s.increment 'queries'

          sql = payload[:sql].strip
          s.increment 'selects' if sql.starts_with?('SELECT')
          s.increment 'inserts' if sql.starts_with?('INSERT')
          s.increment 'updates' if sql.starts_with?('UPDATE')
          s.increment 'deletes' if sql.starts_with?('DELETE')
        end
      end

    end
  end
end