require 'test_helper'

class InstrumentActionTest < ActiveSupport::IntegrationCase

  test 'instrument controller action' do
    visit instrument_action_path
    visit not_instrumented_path

    # puts aggregate.instance_variable_get(:@cache).queued.inspect
    # puts counters.instance_variable_get(:@cache).inspect

    source = 'InstrumentActionController.inst.html'
    source_not_instrumented = 'InstrumentActionController.not_instrumented.html'

    base = 'rails.action.request'
    timings = %w{time time.db time.view}
    timings.each do |t|
      assert_equal 1, aggregate.fetch("#{base}.#{t}", source: source)[:count]
      assert_nil aggregate.fetch("#{base}.#{t}", source: source_not_instrumented)
    end

    assert_equal 1, counters.fetch("#{base}.total", source: source)
  end

  test 'automatically instrument all actions' do
    visit instrument_all_actions_path
    visit still_instrumented_path

    source = 'InstrumentAllActionsController.inst.html'
    source_not_instrumented = 'InstrumentAllActionsController.not_instrumented.html'

    base = 'rails.action.request'
    timings = %w{time time.db time.view}
    timings.each do |t|
      assert_equal 1, aggregate.fetch("#{base}.#{t}", source: source)[:count]
      assert_equal 1, aggregate.fetch("#{base}.#{t}", source: source_not_instrumented)[:count]
    end

    assert_equal 1, counters.fetch("#{base}.total", source: source)
  end
end
