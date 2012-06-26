require 'test_helper'

class NavigationTest < ActiveSupport::IntegrationCase
  
  test 'visiting page records performance statistics' do
    visit root_path
  end
  
end