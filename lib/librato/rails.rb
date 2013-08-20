require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'

require 'librato/rack'
require 'librato/rails/configuration'
require 'librato/rails/tracker'
require 'librato/rails/version'

module Librato
  module Rails
    class << self

      # run once during Rails startup sequence
      def setup(app)
        check_config
        trace_settings if should_log?(:debug)
        return unless should_start?
        if app_server == :other
          log :info, "starting up..."
        else
          log :info, "starting up with #{app_server}..."
        end
        @pid = $$
        app.middleware.use Librato::Rack::Middleware
        start_worker unless forking_server?
      end

    end # end class << self

  end
end

# must load after all module setup
require 'librato/rails/railtie' if defined?(Rails)
require 'librato/rails/subscribers'
