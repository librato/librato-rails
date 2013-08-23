class User < ActiveRecord::Base
  if Rails.version[0..2] == '3.2'
    attr_accessible :email, :password
  end

  def self.do_custom_events
    Librato.group 'custom.model' do |g|
      g.increment 'lookups', 3

      g.timing 'search', 12.3
      g.timing 'search', 6.7

      g.measure 'total', 12
    end
  end

  def touch
    Librato.increment 'custom.model.touch'
  end
end
