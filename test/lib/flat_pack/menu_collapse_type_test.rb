# frozen_string_literal: true

require "test_helper"

module FlatPack
  class MenuCollapseTypeTest < ActiveSupport::TestCase
    test "collapse rows and plain menu rows use the control type size and stay unlayered" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      button = css[/^\.fp-menu-collapse__button \{.*?\n\}/m]
      rows = css[/^\.fp-menu-collapse__items :is\(button, a\),\n\.fp-menu-row \{.*?\n\}/m]

      [button, rows].each do |rule|
        refute_nil rule
        refute_includes rule, "font: inherit"
        refute_includes rule, "font-weight"
        assert_includes rule, "font-family: inherit;"
        assert_includes rule, "font-size: var(--type-control-size);"
        assert_includes rule, "line-height: var(--type-control-leading);"
        assert unlayered_at?(css, css.index(rule)), "expected #{rule.lines.first.strip} to stay outside @layer"
      end
    end

    private

    def unlayered_at?(css, index)
      depth = 0
      layer_depths = []
      pending_layer = false
      i = 0

      while i < index
        if css[i, 2] == "/*"
          close = css.index("*/", i + 2)
          i = close + 2
          next
        end

        if css[i, 6] == "@layer" && css[i + 6].match?(/\s|\{/)
          pending_layer = true
          i += "@layer".length
          next
        end

        if css[i] == "{"
          depth += 1
          if pending_layer
            layer_depths << depth
            pending_layer = false
          end
        elsif css[i] == "}"
          layer_depths.pop if layer_depths.last == depth
          depth -= 1
        end

        i += 1
      end

      layer_depths.empty?
    end
  end
end
