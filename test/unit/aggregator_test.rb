require 'test_helper'

class LibratoRailsAggregatorTest < MiniTest::Unit::TestCase
  
  def test_adding_timings
    agg = Librato::Rails::Aggregator.new
    
    agg.timing 'request.time.total', 23.7
    agg.timing 'request.time.db', 5.3
    agg.timing 'request.time.total', 64.3
    
    assert_equal 2, agg['request.time.total'][:count]
    assert_equal 88.0, agg['request.time.total'][:sum]
  end
  
end
