$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "metrics/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "metrics-rails"
  s.version     = Metrics::Rails::VERSION
  
  s.authors     = ["Matt Sanders"]
  s.email       = ["matt@librato.com"]
  s.homepage    = "https://github.com/librato/metrics-rails"
  
  s.summary     = "Use Librato Metrics with your Rails 3 app"
  s.description = "Report key app statistics to the Librato Metrics service and easily track your own custom metrics."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.0"
  s.add_dependency "librato-metrics", "~> 0.7.0"

  s.add_development_dependency "sqlite3"
end
