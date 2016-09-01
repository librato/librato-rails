require 'test_helper'

class RenderTest < ActiveSupport::IntegrationCase

  test 'render partial' do
    visit render_partial_path

    assert_equal 1, counters.fetch("rails.view.render_partial",
                                      tags: { identifier: "render:first.html.erb" })
    assert_equal 1, counters.fetch("rails.view.render_partial",
                                      tags: { identifier: "render:second.html.erb" })
    assert_equal 1, aggregate.fetch("rails.view.render_partial.time",
                                      tags: { identifier: "render:first.html.erb" })[:count]
    assert_equal 1, aggregate.fetch("rails.view.render_partial.time",
                                      tags: { identifier: "render:second.html.erb" })[:count]
  end

  test 'render template' do
    visit render_template_path

    assert_equal 1, counters.fetch("rails.view.render_template",
                                      tags: { identifier: "render:template.html.erb" })
    assert_equal 1, aggregate.fetch("rails.view.render_template.time",
                                      tags: { identifier: "render:template.html.erb" })[:count]
  end

end
