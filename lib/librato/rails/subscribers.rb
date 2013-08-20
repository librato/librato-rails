require 'active_support/notifications'

module Librato
  module Rails

    # defines the basic context that all of the librato-rails subscribers
    # wil run in
    #
    module Subscribers

      # make the collector object directly available since it won't
      # be changing
      def self.collector
        @collector ||= Librato.tracker.collector
      end

    end
  end
end

require_relative 'subscribers/controller'
require_relative 'subscribers/sql'
require_relative 'subscribers/mail'