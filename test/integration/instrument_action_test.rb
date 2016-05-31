require 'test_helper'

class InstrumentActionTest < ActiveSupport::IntegrationCase

  test 'instrument controller action' do
    visit instrument_action_path

    # puts aggregate.instance_variable_get(:@cache).queued.inspect
    # puts counters.instance_variable_get(:@cache).inspect

    source = 'InstrumentActionController.inst.html'

    base = 'rails.action.request'
    timings = %w{time time.db time.view}
    timings.each do |t|
      assert_equal 1, aggregate.fetch("#{base}.#{t}", source: source)[:count]
    end

    assert_equal 1, counters.fetch("#{base}.total", source: source)
  end

  test 'instrument all controller actions' do
    visit base_action_1_path
    visit base_action_2_path

    metric = 'rails.action.request.time'

    assert_equal 1, aggregate.fetch(metric, source: 'BaseController.action_1.html')[:count]
    assert_equal 1, aggregate.fetch(metric, source: 'BaseController.action_2.html')[:count]
  end

  test 'instrument all controller actions for inherited controllers' do
    visit intermediate_action_1_path
    visit derived_action_1_path
    visit derived_action_2_path

    metric = 'rails.action.request.time'

    assert_equal 1, aggregate.fetch(metric, source: 'IntermediateController.action_1.html')[:count]
    assert_equal 1, aggregate.fetch(metric, source: 'DerivedController.action_1.html')[:count]
    assert_equal 1, aggregate.fetch(metric, source: 'DerivedController.action_2.html')[:count]
  end

  test 'instrument all controller actions for all controllers' do
    visit not_instrumented_path

    metric = 'rails.action.request.time'

    assert_equal 1, aggregate.fetch(metric, source: 'InstrumentActionController.not.html')[:count]
  end

end
