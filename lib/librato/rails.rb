require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/notifications'

require 'librato/rack'
require 'librato/rails/configuration'
require 'librato/rails/tracker'
require 'librato/rails/version'

# must load after all module setup
require 'librato/rails/railtie' if defined?(Rails)
require 'librato/rails/subscribers'
