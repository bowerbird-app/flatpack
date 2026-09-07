# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Toasts
    module Region
      class ComponentTest < ViewComponent::TestCase
        def test_uses_toast_region_class_instead_of_inline_offsets
          render_inline(Component.new)

          html = page.native.to_html

          assert_includes html, "fp-toast-region"
          refute_includes html, "top: calc(72px"
          refute_includes html, "height: 72px"
        end
      end
    end
  end
end
