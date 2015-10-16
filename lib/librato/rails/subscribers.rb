require 'active_support/notifications'

module Librato
  module Rails

    # defines basic context that all librato-rails subscribers will run in
    module Subscribers

      # make collector object directly available, it won't be changing
      def self.collector
        @collector ||= Librato.tracker.collector
      end

    end
  end
end

require_relative 'subscribers/cache'
require_relative 'subscribers/controller'
require_relative 'subscribers/render'
require_relative 'subscribers/sql'
require_relative 'subscribers/mail'

VersionSpecifier.supported(min: '4.2') do
  require_relative 'subscribers/job'
end
