source "https://rubygems.org"
gemspec

rails_version = ENV["RAILS_VERSION"] || '4.2'
if rails_version == "master"
  rails = {github: "rails/rails"}
else
  rails = "~> #{rails_version}.0"
end

gem "mime-types", (rails_version >= "4.0" ? "~> 2.9" : "~> 1.16")
gem "railties", rails
gem "activesupport", rails

# debugging
gem 'pry'

# mocks
gem 'mocha', require: false

# benchmarking
gem 'benchmark_suite'

platforms :ruby_19 do
  gem 'nokogiri', '~> 1.6.0' # 1.7+ requires ruby 2.1
end

# platforms :rbx do
#   gem 'rubysl', '~> 2.0'
#   gem 'racc'
#   gem 'rubysl-test-unit'
#   gem 'rubinius-developer_tools'
# end

# servers for testing
# gem 'thin'
# gem 'unicorn'

group :test do
  gem "rails", rails
end
