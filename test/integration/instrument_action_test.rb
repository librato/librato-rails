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

end
