module Librato
  module Rails
    class Tracker < Rack::Tracker

      private

      def version_string
        "librato-rails/#{Librato::Rails::VERSION}"
      end

    end
  end
end