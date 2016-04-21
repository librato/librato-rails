require 'active_support/notifications'

module Librato
  module Rails

    # defines basic context that all librato-rails subscribers will run in
    module Subscribers

      # make collector object directly available, it won't be changing
      def self.collector
        @collector ||= Librato.tracker.collector
      end

      def self.watch_controller_action(controller, action)
        @watches ||= []
        @watches << "#{controller}##{action}".freeze
      end
    end
  end
end
