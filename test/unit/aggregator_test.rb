require 'test_helper'

class LibratoRailsAggregatorTest < MiniTest::Unit::TestCase
  
  def setup
    @agg = Librato::Rails::Aggregator.new
  end
  
  def test_adding_timings
    @agg.timing 'request.time.total', 23.7
    @agg.timing 'request.time.db', 5.3
    @agg.timing 'request.time.total', 64.3
    
    assert_equal 2, @agg['request.time.total'][:count]
    assert_equal 88.0, @agg['request.time.total'][:sum]
  end
  
  def test_block_timing
    @agg.timing 'my.task' do
      sleep 0.2
    end
    assert_in_delta @agg['my.task'][:sum], 200, 50
    
    @agg.timing('another.task') { sleep 0.1 }
    assert_in_delta @agg['another.task'][:sum], 100, 50
  end
  
  def test_return_values
    simple = @agg.timing 'simple', 20
    assert_equal nil, simple
    
    timing = @agg.timing 'foo' do
      sleep 0.1
      'bar'
    end
    assert_equal 'bar', timing
  end
  
  def test_custom_source
    # sources are kept separate
    @agg.measure 'meaning.of.life', 1
    @agg.measure 'meaning.of.life', 42, :source => 'douglas_adams'
    assert_equal 1.0, @agg.fetch('meaning.of.life')[:sum]
    assert_equal 42.0, @agg.fetch('meaning.of.life', :source => 'douglas_adams')[:sum]
    
    # sources work with time blocks
    @agg.timing 'mytiming', :source => 'mine' do
      sleep 0.02
    end
    assert_in_delta @agg.fetch('mytiming', :source => 'mine')[:sum], 20, 10
  end
  
end
