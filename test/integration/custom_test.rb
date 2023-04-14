require 'test_helper'

class CustomTest < ActiveSupport::IntegrationCase

  test 'controller access' do
    visit custom_path

    assert_equal 1, counters['custom.visits'][:value]
    assert_equal 3, counters['custom.events'][:value]

    assert_equal 12, aggregate['custom.timing'][:sum]
    assert_equal 2, aggregate['custom.timing'][:count]
  end

  test 'model class access' do
    visit custom_path

    assert_equal 3, counters['custom.model.lookups'][:value]
    assert_equal 19.0, aggregate['custom.model.search'][:sum]
    assert_equal 2, aggregate['custom.model.search'][:count]
  end

  test 'model instance access' do
    visit custom_path

    assert_equal 1, counters['custom.model.touch'][:value]
  end

end
