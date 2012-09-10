require 'test_helper'

class MetricRackMiddlewareTest < MiniTest::Unit::TestCase

  def setup
    Librato::Rails.stubs(:forking_server?).returns(false)
    Librato::Rails.stubs(:measure).returns(true)
    Librato::Rails.stubs(:increment).returns(true)

    Time.stubs(:now).returns(Time.at(0.1305), Time.at(0.20075))

    @middleware = Librato::Rack::Middleware.new(
      stub(:call => [200, {}, []])
    )
  end

  def teardown
    Librato::Rails.unstub :forking_server?, :measure, :increment
    Time.unstub :now
  end

  def test_logs_header_metrics
    Librato::Rails.expects(:measure).with('rack.heroku.queue.depth', 1.0)
    Librato::Rails.expects(:measure).with('rack.heroku.queue.wait_time', 20.5)
    Librato::Rails.expects(:measure).with('rack.heroku.queue.dynos', 2.0)

    @middleware.call(
      'HTTP_X_HEROKU_QUEUE_DEPTH'     => '1',
      'HTTP_X_HEROKU_QUEUE_WAIT_TIME' => '20.5',
      'HTTP_X_HEROKU_DYNOS_IN_USE'    => '2'
    )
  end

  def test_logs_request_time
    Librato::Rails.expects(:measure).with('rack.request.time', 70.25)

    @middleware.call({})
  end

  def test_increments_request_count
    Librato::Rails.expects(:increment).with('rack.request.total', 1)

    @middleware.call({})
  end

  def test_log_200_status
    Librato::Rails.expects(:increment).with('rack.request.status.200', 1)
    Librato::Rails.expects(:increment).with('rack.request.status.2xx', 1)

    Librato::Rails.expects(:measure).with('rack.request.status.200.time', 70.25)
    Librato::Rails.expects(:measure).with('rack.request.status.2xx.time', 70.25)

    @middleware.call({})
  end

  def test_log_403_status
    Librato::Rails.expects(:increment).with('rack.request.status.403', 1)
    Librato::Rails.expects(:increment).with('rack.request.status.4xx', 1)

    Librato::Rails.expects(:measure).with('rack.request.status.403.time', 70.25)
    Librato::Rails.expects(:measure).with('rack.request.status.4xx.time', 70.25)

    @middleware = Librato::Rack::Middleware.new stub(:call => [403, {}, []])
    @middleware.call({})
  end

  def test_fast_queries_are_not_slow
    Time.stubs(:now).returns(0.1305, 0.3305)

    Librato::Rails.expects(:increment).with('rack.request.slow', 1).never

    @middleware.call({})
  end

  def test_log_slow_queries
    Time.stubs(:now).returns(0.1305, 0.40075)

    Librato::Rails.expects(:increment).with('rack.request.slow', 1)

    @middleware.call({})
  end
end
