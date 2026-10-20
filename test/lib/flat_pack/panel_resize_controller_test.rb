# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class PanelResizeControllerTest < ActiveSupport::TestCase
    test "desktop drag keyboard and collapse stay in the resize controller" do
      test_file = FlatPack::Engine.root.join("test/javascript/panel_resize_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "resized selectors beat the content width rule in kit and dummy css" do
      sheets = [
        FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read,
        FlatPack::Engine.root.join("test/dummy/app/assets/stylesheets/application.tailwind.css").read
      ]
      content = '[data-flat-pack-sidebar-collapsed="false"][data-flat-pack-sidebar-width="content"] aside'
      resized = '[data-flat-pack-panel-resized="true"][data-flat-pack-sidebar-collapsed="false"][data-flat-pack-sidebar-width="content"] aside'

      sheets.each do |sheet|
        compact = sheet.gsub(/\s+/, " ")
        content_at = compact.index(content)
        resized_at = compact.index(resized)

        assert content_at, "missing content width selector"
        assert resized_at, "missing resized content selector"
        assert_operator resized_at, :>, content_at
        assert_operator (selector_rank(resized) <=> selector_rank(content)), :>=, 0
        assert_includes compact, "width: var(--fp-panel-width) !important"
        assert_includes compact, '.fp-sidebar-drawer[data-flat-pack-panel="aside"] > .fp-aside { width: 100% !important'
        assert_includes compact, "display: none !important"
      end

      controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/panel_resize_controller.js").read
      refute_includes controller, "style.width"
      refute_includes controller, "prefers-reduced-motion"
    end

    private

    def selector_rank(selector)
      working = selector.gsub(/:not\(([^)]*)\)/, "\\1")
      ids = working.scan(/#[A-Za-z0-9_-]+/).length
      attributes = working.scan(/\[[^\]]+\]/).length
      classes = working.scan(/\.[\w-]+/).length
      pseudos = working.scan(/:(?!not\b)[\w-]+/).length
      stripped = working.gsub(/\[[^\]]+\]/, " ").gsub(/\.[\w-]+/, " ").gsub(/::?[\w-]+/, " ")
      elements = stripped.scan(/[a-zA-Z][\w-]*/).length
      [ids, attributes + classes + pseudos, elements]
    end
  end
end
