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

        watch =
          if action == :all
            "#{controller}".freeze
          else
            "#{controller}##{action}".freeze
          end

        @watches << watch
      end

      def self.inherit_watches(base, descendant)
        @watches ||= []
        @watches << descendant.freeze if @watches.include?(base)
      end
    end
  end
end
