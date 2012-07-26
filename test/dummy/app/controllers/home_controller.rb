class HomeController < ApplicationController
  def index
  end
  
  def custom
    # controller helpers
    Metrics.group 'custom' do |g|
      g.increment 'visits'
      g.increment 'events', 3
    
      g.timing 'timing', 3
      g.timing 'timing', 9
    end
    
    # test class-level helpers for models
    User.do_custom_events
    
    # test instance-level helpers for models
    user = User.new
    user.touch
    
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
