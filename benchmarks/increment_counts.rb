$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'
require 'librato/rails'

Benchmark.ips do |x|
  x.report('simple increment') do
    Librato::Rails.increment :foo
  end

  x.report('multiple increments') do
    z = rand(1000)
    Librato::Rails.increment z.to_s
  end
end