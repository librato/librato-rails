class InstrumentActionController < ApplicationController
  # extend Librato::Rails::Helpers::Controller

  before_filter :before
  instrument_action :inst

  def inst
    Librato.timing 'internal execution' do
      render nothing: true
    end
  end

  def not
    render nothing: true
  end

  private

  def before
    sleep 1
  end
end
