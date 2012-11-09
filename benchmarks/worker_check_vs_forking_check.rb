$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'
require 'librato/rails'

module Librato::Rails
  @pid == $$
end

Benchmark.ips do |x|
  x.report('worker check') do
    Librato::Rails.check_worker
  end

  x.report('forking server check') do
    Librato::Rails.send(:forking_server?)
  end
end