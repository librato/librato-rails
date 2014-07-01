$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'

controller = 'MyFooController'
action = 'my_action'

frozen = ["#{controller}##{action}".freeze]
symbols = [:"#{controller}##{action}"]

Benchmark.ips do |x|
  x.report('symbol') do
    symbols.index(:"#{controller}##{action}")
  end

  x.report('frozen') do
    frozen.index("#{controller}##{action}".freeze)
  end

  x.report('not frozen') do
    frozen.index("#{controller}##{action}")
  end
end

# ruby 2.1.2
# Calculating -------------------------------------
#               symbol     52508 i/100ms
#               frozen     57005 i/100ms
#           not frozen     59465 i/100ms
# -------------------------------------------------
#               symbol  1209129.9 (±0.7%) i/s -    6090928 in   5.037718s
#               frozen  1350766.1 (±2.3%) i/s -    6783595 in   5.025281s
#           not frozen  1402302.1 (±3.7%) i/s -    7016870 in   5.013521s

# ruby 1.9.3
# Calculating -------------------------------------
#               symbol     37277 i/100ms
#               frozen     40160 i/100ms
#           not frozen     42275 i/100ms
# -------------------------------------------------
#               symbol   713515.2 (±15.1%) i/s -   3504038 in   5.033141s
#               frozen   853218.2 (±3.4%) i/s -    4297120 in   5.042635s
#           not frozen   924651.7 (±2.7%) i/s -    4650250 in   5.032794s