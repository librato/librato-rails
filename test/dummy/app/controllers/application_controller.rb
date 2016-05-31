class ApplicationController < ActionController::Base
  protect_from_forgery
  instrument_action :all
  #after_filter :flush_metrics_rails

  # manually flush per request
  def flush_metrics_rails
    Librato::Rails.flush
  end
end
