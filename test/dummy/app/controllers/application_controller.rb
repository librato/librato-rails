class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #after_filter :flush_metrics_rails
  
  # manually flush per request
  def flush_metrics_rails
    Metrics::Rails.flush
  end
end
