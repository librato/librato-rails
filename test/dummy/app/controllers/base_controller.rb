class BaseController < ApplicationController
  instrument_action :all

  def action_1
    render nothing: true
  end

  def action_2
    render nothing: true
  end
end
