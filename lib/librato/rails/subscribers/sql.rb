module Librato
  module Rails
    module Subscribers

      # SQL

      ActiveSupport::Notifications.subscribe "sql.active_record" do |*args|

        payload = args.last
        sql = payload[:sql].strip

        collector.group "rails.sql" do |s|
          s.increment "queries"
          s.increment "selects" if sql.starts_with?("SELECT")
          s.increment "inserts" if sql.starts_with?("INSERT")
          s.increment "updates" if sql.starts_with?("UPDATE")
          s.increment "deletes" if sql.starts_with?("DELETE")
        end # end group

      end # end subscribe

    end
  end
end
