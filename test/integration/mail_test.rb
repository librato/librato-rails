require 'test_helper'

class MailTest < ActiveSupport::IntegrationCase

  # Query tests - the numbers specified assume running against SQLite

  test 'mail sent' do
    user = User.create!(:email => 'foo@foo.com', :password => 'wow')
    UserMailer.welcome_email(user).deliver
    assert_equal 1, counters["rails.mail.sent"]
  end

end
