class HomeController < ApplicationController
  def index
  end
  
  def custom
    metrics.group 'custom' do |g|
      g.increment 'visits'
      g.increment 'events', 3
    
      g.timing 'timing', 3
      g.timing 'timing', 9
    end
    
    # User.do_custom_events
    render :nothing => true
  end
  
  def boom
    raise 'test exception!'
  end
  
  def slow
    sleep 0.3
    render :nothing => true
  end
end
