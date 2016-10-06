require 'test_helper'

class RenderTest < ActiveSupport::IntegrationCase

  test 'render partial' do
    visit render_partial_path

    assert_equal 1, counters.fetch("rails.view.render",
                                      tags: { view: "partial", identifier: "render:first.html.erb" })[:value]
    assert_equal 1, counters.fetch("rails.view.render",
                                      tags: { view: "partial", identifier: "render:second.html.erb" })[:value]
    assert_equal 1, aggregate.fetch("rails.view.render.time",
                                      tags: { view: "partial", identifier: "render:first.html.erb" })[:count]
    assert_equal 1, aggregate.fetch("rails.view.render.time",
                                      tags: { view: "partial", identifier: "render:second.html.erb" })[:count]
  end

  test 'render template' do
    visit render_template_path

    assert_equal 1, counters.fetch("rails.view.render",
                                      tags: { view: "template", identifier: "render:template.html.erb" })[:value]
    assert_equal 1, aggregate.fetch("rails.view.render.time",
                                      tags: { view: "template", identifier: "render:template.html.erb" })[:count]
  end

end
