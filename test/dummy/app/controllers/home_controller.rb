class HomeController < ApplicationController
  def index
  end
  
  def boom
    raise 'test exception!'
  end
end
