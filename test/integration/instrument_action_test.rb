require 'test_helper'

class InstrumentActionTest < ActiveSupport::IntegrationCase

  test "instrument controller action" do
    tags = {
      controller: "InstrumentActionController",
      action: "inst",
      format: "html"
    }.merge(default_tags)

    visit instrument_action_path

    base = "rails.request"
    timings = %w{time time.db time.view}
    timings.each do |t|
      assert_equal 1, aggregate.fetch("#{base}.#{t}", tags: tags)[:count]
    end

    assert_equal 1, counters.fetch("#{base}.total", tags: tags)[:value]
  end

  test "instrument all controller actions" do
    visit base_action_1_path
    visit base_action_2_path

    metric = "rails.request.time"

    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "BaseController",
        action: "action_1",
        format: "html"
      }.merge(default_tags))[:count]
    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "BaseController",
        action: "action_2",
        format: "html"
      }.merge(default_tags))[:count]
  end

  test "instrument all controller actions for inherited controllers" do
    visit intermediate_action_1_path
    visit derived_action_1_path
    visit derived_action_2_path

    metric = "rails.request.time"

    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "IntermediateController",
        action: "action_1",
        format: "html"
      }.merge(default_tags))[:count]
    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "DerivedController",
        action: "action_1",
        format: "html"
      }.merge(default_tags))[:count]
    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "DerivedController",
        action: "action_2",
        format: "html"
      }.merge(default_tags))[:count]
  end

  test "instrument all controller actions for all controllers" do
    visit not_instrumented_path

    metric = "rails.request.time"

    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "InstrumentActionController",
        action: "not",
        format: "html"
      }.merge(default_tags))[:count]
  end

  test "instrument invalid format" do
    Capybara.current_session.driver.header "Accept", "*/*"

    visit "/invalid_format"

    metric = "rails.request.time"

    assert_equal 1, aggregate.fetch(metric,
      tags: {
        controller: "InstrumentActionController",
        action: "invalid_format",
        format: "all"
      }.merge(default_tags))[:count]

    Capybara.current_session.driver.header "Accept", nil
  end

end
