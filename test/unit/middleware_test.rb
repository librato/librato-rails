require 'minitest/autorun'
require 'mocha'
require 'metrics/rails'

class MetricRackMiddlewareTest < MiniTest::Unit::TestCase
  include Mocha::API

  def setup
    Metrics::Rails.stubs(:forking_server?).returns(false)
    Metrics::Rails.stubs(:measure).returns(true)
    Metrics::Rails.stubs(:increment).returns(true)

    Time.stubs(:now).returns(Time.at(0.1305), Time.at(0.20075))

    @middleware = Metrics::Rack::Middleware.new(
      stub(:call => [200, {}, []]), Metrics::Rails
    )
  end

  def teardown
    Metrics::Rails.unstub :forking_server?, :measure, :increment
    Time.unstub :now
  end

  def test_logs_header_metrics
    Metrics::Rails.expects(:measure).with('rack.heroku.queue.depth', 1.0)
    Metrics::Rails.expects(:measure).with('rack.heroku.queue.wait_time', 20.5)
    Metrics::Rails.expects(:measure).with('rack.heroku.queue.dynos', 2.0)

    @middleware.call(
      'HTTP_X_HEROKU_QUEUE_DEPTH'     => '1',
      'HTTP_X_HEROKU_QUEUE_WAIT_TIME' => '20.5',
      'HTTP_X_HEROKU_DYNOS_IN_USE'    => '2'
    )
  end

  def test_logs_request_time
    Metrics::Rails.expects(:measure).with('rack.request.time', 70.25)

    @middleware.call({})
  end

  def test_increments_request_count
    Metrics::Rails.expects(:increment).with('rack.request.total', 1)

    @middleware.call({})
  end

  def test_log_200_status
    Metrics::Rails.expects(:increment).with('rack.request.status.200', 1)
    Metrics::Rails.expects(:increment).with('rack.request.status.2xx', 1)

    Metrics::Rails.expects(:measure).with('rack.request.status.200.time', 70.25)
    Metrics::Rails.expects(:measure).with('rack.request.status.2xx.time', 70.25)

    @middleware.call({})
  end

  def test_log_403_status
    Metrics::Rails.expects(:increment).with('rack.request.status.403', 1)
    Metrics::Rails.expects(:increment).with('rack.request.status.4xx', 1)

    Metrics::Rails.expects(:measure).with('rack.request.status.403.time', 70.25)
    Metrics::Rails.expects(:measure).with('rack.request.status.4xx.time', 70.25)

    @middleware = Metrics::Rack::Middleware.new stub(:call => [403, {}, []])
    @middleware.call({})
  end

  def test_fast_queries_are_not_slow
    Time.stubs(:now).returns(0.1305, 0.3305)

    Metrics::Rails.expects(:increment).with('rack.request.slow', 1).never

    @middleware.call({})
  end

  def test_log_slow_queries
    Time.stubs(:now).returns(0.1305, 0.40075)

    Metrics::Rails.expects(:increment).with('rack.request.slow', 1)

    @middleware.call({})
  end
end
