class HomeController < ApplicationController
  def index
  end
  
  def boom
    raise 'test exception!'
  end
  
  def slow
    sleep 0.3
    render :nothing => true
  end
end
