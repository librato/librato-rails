require 'test_helper'

class RenderTest < ActiveSupport::IntegrationCase

  test 'render partial' do
    visit render_partial_path

    assert_equal 1, counters.fetch("rails.view.render_partial",
                                      source: 'render:first.html.erb')
    assert_equal 1, counters.fetch("rails.view.render_partial",
                                      source: 'render:second.html.erb')
    assert_equal 1, aggregate.fetch("rails.view.render_partial.time",
                                      source: 'render:first.html.erb')[:count]
    assert_equal 1, aggregate.fetch("rails.view.render_partial.time",
                                      source: 'render:second.html.erb')[:count]
  end

  test 'render template' do
    visit render_template_path

    assert_equal 1, counters.fetch("rails.view.render_template",
                                      source: 'render:template.html.erb')
    assert_equal 1, aggregate.fetch("rails.view.render_template.time",
                                      source: 'render:template.html.erb')[:count]
  end

end
