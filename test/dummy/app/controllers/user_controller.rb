class UserController < ApplicationController
  
  def manipulation
    user = User.create!(:email => 'foo@foo.com', :password => 'wow')
    foo = User.find_by_email('foo@foo.com')
    foo.password = 'new password'
    foo.save
    render :nothing => true
  end
  
end
