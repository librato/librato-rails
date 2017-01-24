require 'test_helper'

class MailTest < ActiveSupport::IntegrationCase

  test 'mail sent' do
    user = User.create!(:email => 'foo@foo.com', :password => 'wow')
    tags = { mailer: "UserMailer" }.merge(default_tags)
    UserMailer.welcome_email(user).deliver
    assert_equal 1, counters.fetch("rails.mail.sent", tags: tags)[:value]
  end

  test "mail received" do
    user = User.create!(email: "foo@foo.com", password: "foobar")
    tags = { mailer: "UserMailer" }.merge(default_tags)
    UserMailer.receive(user.email)
    assert_equal 1, counters.fetch("rails.mail.received", tags: tags)[:value]
  end

end
