require 'test_helper'

class MetricsRailsWorkerTest < MiniTest::Unit::TestCase
  
  def test_basic_use
    worker = Metrics::Rails::Worker.new
    counter = 0
    Thread.new do
      worker.run_periodically(0.1) do
        counter += 1
      end
    end
    sleep 0.45
    assert_equal counter, 4
  end
  
  def test_start_time
    worker = Metrics::Rails::Worker.new
    
    time = Time.now
    start = worker.start_time(60)
    assert start >= time + 60, 'should be more than 60 seconds from when run'
    assert_equal 0, start.sec, 'should start on a whole minute'
    
    time = Time.now
    start = worker.start_time(10)
    assert start >= time + 10, 'should be more than 10 seconds from when run'
    assert_equal 0, start.sec%10, 'should be evenly divisible with whole minutes'
  end
  
end
