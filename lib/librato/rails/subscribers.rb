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

        return @watches if @watches.include?(watch)
        @watches << watch
      end

      def self.watch_controller_descendants_for(controller)
        klass = controller.is_a?(String) ? controller.constantize : controller
        return @watches if klass.descendants.empty? # base case

        klass.descendants.each do |descendant|
          Subscribers.watch_controller_action(descendant, :all)
          Subscribers.watch_controller_descendants_for(descendant)
        end

        @watches
      end

      def self.track_controller_descendants
        controllers = @watches.reject { |c| c.include?('#') } # specific controller actions do not have descendants
        controllers.each { |c| Subscribers.watch_controller_descendants_for(c) }
      end
    end
  end
end
