class UserController < ApplicationController
  
  def manipulation
    email = "rand#{rand(10000)}@foo.com"
    user = User.create!(:email => email, :password => 'wow')
    foo = User.find_by_email(email)
    foo.password = 'new password'
    foo.save
    foo.destroy
    render :nothing => true
  end
  
end
