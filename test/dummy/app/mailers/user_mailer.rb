class UserMailer < ActionMailer::Base
  default from: "from@librato-rails.com"

  def welcome_email(user)
    @user = user
    mail(:to => user.email, :subject => "Why Howdy!")
  end

  def receive(email)
    email
  end
end
