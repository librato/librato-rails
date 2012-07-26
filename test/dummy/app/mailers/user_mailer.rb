class UserMailer < ActionMailer::Base
  default from: "from@metrics-rails.com"
  
  def welcome_email(user)
    @user = user
    mail(:to => user.email, :subject => "Why Howdy!")
  end
end
