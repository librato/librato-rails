require 'test_helper'

class RenderTest < ActiveSupport::IntegrationCase

  test 'render partial' do
    visit render_partial_path

    assert_equal 1, counters.fetch("rails.view.render.partial",
                                      tags: { partial: "render:first.html.erb" }.merge(default_tags))[:value]
    assert_equal 1, counters.fetch("rails.view.render.partial",
                                      tags: { partial: "render:second.html.erb" }.merge(default_tags))[:value]
    assert_equal 1, aggregate.fetch("rails.view.render.partial.time",
                                      tags: { partial: "render:first.html.erb" }.merge(default_tags))[:count]
    assert_equal 1, aggregate.fetch("rails.view.render.partial.time",
                                      tags: { partial: "render:second.html.erb" }.merge(default_tags))[:count]
  end

  test 'render template' do
    visit render_template_path

    assert_equal 1, counters.fetch("rails.view.render.template",
                                      tags: { template: "render:template.html.erb" }.merge(default_tags))[:value]
    assert_equal 1, aggregate.fetch("rails.view.render.template.time",
                                      tags: { template: "render:template.html.erb" }.merge(default_tags))[:count]
  end

end
