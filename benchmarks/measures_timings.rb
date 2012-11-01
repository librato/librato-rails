$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'
require 'librato/rails'

Benchmark.ips do |x|
  x.report('simple measure') do
    Librato::Rails.measure :foo, 23.2
  end

  x.report('simple random') do
    Librato::Rails.measure :foo, rand(1000)
  end

  x.report('multiple measures') do
    z = rand(1000)
    Librato::Rails.measure z.to_s, 100.3
  end

  x.report('multiple random') do
    z = rand(1000)
    Librato::Rails.measure z.to_s, rand(1000)
  end

  x.report('simple timing') do
    Librato::Rails.timing :bar do
      10.2
    end
  end

  x.report('multiple timing') do
    z = rand(1000)
    Librato::Rails.timing z.to_s do
      200.1
    end
  end
end