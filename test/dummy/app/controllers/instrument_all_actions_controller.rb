class InstrumentAllActionsController < ApplicationController
  # extend Librato::Rails::Helpers::Controller
  # before_filter :before

  instrument_action

  def inst
    Librato.timing 'internal execution' do
      render nothing: true
    end
  end

  def not_instrumented
    render nothing: true
  end

  private

  def before
    sleep 1
  end
end
