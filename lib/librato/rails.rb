require 'librato/rack'
require 'librato/rails/configuration'
require 'librato/rails/tracker'
require 'librato/rails/version'

# must load after all module setup and in this order
if defined?(Rails)
  require 'librato/rails/railtie'
  require 'librato/rails/subscribers'
end