require 'librato/rack'
require_relative 'rails/configuration'
require_relative 'rails/tracker'
require_relative 'rails/version'

# must load after all module setup and in this order
if defined?(Rails)
  require_relative 'rails/railtie'
  require_relative 'rails/subscribers'
end