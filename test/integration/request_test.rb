require 'test_helper'

class RequestTest < ActiveSupport::IntegrationCase

  # Each request

  test 'increment total and status' do
    tags_1 = {
      controller: "HomeController",
      action: "index",
      format: "html"
    }

    visit root_path

    assert_equal 1, counters.fetch("rails.request.total", tags: tags_1)
    assert_equal 1, counters.fetch("rails.request.status", tags: { status: 200, status_message: "OK" })
    assert_equal 1, counters.fetch("rails.request.method", tags: { method: "get" })

    visit root_path

    assert_equal 2, counters.fetch("rails.request.total", tags: tags_1)

    tags_2 = {
      controller: "StatusController",
      action: "index",
      format: "html"
    }

    visit '/status/204'

    assert_equal 1, counters.fetch("rails.request.total", tags: tags_2)
    assert_equal 1, counters.fetch("rails.request.status", tags: { status: 204, status_message: "No Content" })
  end

  test 'request times' do
    expected_tags = {
      controller: "HomeController",
      action: "index",
      format: "html"
    }

    visit root_path

    # common for all paths
    assert_equal 1, aggregate.fetch("rails.request.time", tags: expected_tags)[:count],
      'should record total time'
    assert_equal 1, aggregate.fetch("rails.request.time.db", tags: expected_tags)[:count],
      'should record db time'
    assert_equal 1, aggregate.fetch("rails.request.time.view", tags: expected_tags)[:count],
      'should record view time'

    # status specific
    assert_equal 1, aggregate.fetch("rails.request.status.time", tags: { status: 200, status_message: "OK" })[:count]

    # http method specific
    assert_equal 1, aggregate.fetch("rails.request.method.time", tags: { method: "get" })[:count]
  end

  test 'track slow requests' do
    expected_tags = {
      controller: "HomeController",
      action: "slow",
      format: "html"
    }

    visit slow_path
    assert_equal 1, counters.fetch("rails.request.slow", tags: expected_tags)
  end

end
