require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase

  # Each request

  test 'increment total and status' do
    visit root_path

    assert_equal 1, counters["rails.request.total"]
    assert_equal 1, counters["rails.request.status.200"]
    assert_equal 1, counters["rails.request.status.2xx"]
    assert_equal 1, counters["rails.request.method.get"]

    visit '/status/204'

    assert_equal 2, counters["rails.request.total"]
    assert_equal 1, counters["rails.request.status.200"]
    assert_equal 1, counters["rails.request.status.204"]
    assert_equal 2, counters["rails.request.status.2xx"]
  end

  test 'request times' do
    visit root_path

    # common for all paths
    assert_equal 1, aggregate["rails.request.time"][:count], 'should record total time'
    assert_equal 1, aggregate["rails.request.time.db"][:count], 'should record db time'
    assert_equal 1, aggregate["rails.request.time.view"][:count], 'should record view time'

    # status specific
    assert_equal 1, aggregate["rails.request.status.200.time"][:count]
    assert_equal 1, aggregate["rails.request.status.2xx.time"][:count]

    # http method specific
    assert_equal 1, aggregate["rails.request.method.get.time"][:count]
  end

  test 'track exceptions' do
    begin
      visit exception_path #rescue nil
    rescue RuntimeError => e
      raise unless e.message == 'test exception!'
    end
    assert_equal 1, counters["rails.request.exceptions"]
  end

  test 'track slow requests' do
    visit slow_path
    assert_equal 1, counters["rails.request.slow"]
  end

end