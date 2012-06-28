require 'test_helper'

class MetricsRailsWorkerTest < ActiveSupport::TestCase
  
  test 'basic use' do
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
  
end
