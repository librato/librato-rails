source "http://rubygems.org"
gemspec

rails_version = ENV["RAILS_VERSION"] || '3.2.14'
if rails_version == "master"
  rails = {github: "rails/rails"}
else
  rails = "~> #{rails_version}"
end

gem "rails", rails

# debugging
gem 'pry'

# mocks
gem 'mocha', :require => false

# benchmarking
gem 'benchmark_suite'

# servers for testing
# gem 'thin'
# gem 'unicorn'
