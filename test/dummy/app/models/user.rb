class User < ActiveRecord::Base
  attr_accessible :email, :password
end
