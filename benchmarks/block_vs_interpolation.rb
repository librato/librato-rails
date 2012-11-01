$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'

def log_block(&block); nil; end
def log(string); nil; end

first, second, third = %w{foo bar baz}

Benchmark.ips do |x|
  x.report('interpolation no var') do
    log "so simple"
  end

  x.report('interpolation 1 var') do
    log "my #{first} var"
  end

  x.report('interpolation 2 var') do
    log "my #{first} var is #{second}"
  end

  x.report('interpolation 3 var') do
    log "my #{first} var is #{second} and #{third}"
  end

  x.report('block no var') do
    log_block { "so simple" }
  end

  x.report('block 1 var') do
    log_block { "my #{first} var" }
  end

  x.report('block 2 var') do
    log_block { "my #{first} var is #{second}" }
  end

  x.report('block 3 var') do
    log_block { "my #{first} var is #{second} and #{third}" }
  end
end
