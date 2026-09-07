# frozen_string_literal: true

require "test_helper"

module FlatPack
  class OverlayContainmentTest < ActiveSupport::TestCase
    test "kit CSS contains overlay scroll, touch, and safe-area rules" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      assert_includes css, "touch-action: manipulation"
      assert_includes css, ".fp-touch-manipulation"
      assert_includes css, ".fp-overlay-pad"
      assert_includes css, ".fp-top-nav"
      assert_includes css, ".fp-toast-region"
      assert_includes css, ".fp-bottom-nav"
      assert_includes css, ".fp-sidebar-drawer"
      assert_includes css, "overscroll-behavior: contain"
      assert_includes css, "env(safe-area-inset-top, 0px)"
      assert_includes css, "env(safe-area-inset-right, 0px)"
      assert_includes css, "env(safe-area-inset-bottom, 0px)"
      assert_includes css, "env(safe-area-inset-left, 0px)"
      assert_includes css, "[data-controller~=\"flat-pack--modal\"]"
      assert_includes css, "[data-flat-pack--carousel-target=\"lightbox\"]"
      assert_includes css, ".flat-pack-modal__body"
    end

    test "modal body lock also sets overscroll-behavior none" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/modal_controller.js").read

      assert_includes js, 'document.body.style.overscrollBehavior = "none"'
      assert_includes js, 'document.body.style.removeProperty("overscroll-behavior")'
    end

    test "toast fallback container uses the toast region class instead of inline offsets" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/toasts_region_controller.js").read

      assert_includes js, "fp-toast-region"
      refute_includes js, "container.style.top"
      refute_includes js, "container.style.right"
    end

    test "layout generator and dummy layouts set viewport-fit cover" do
      paths = [
        "lib/generators/flat_pack/templates/layout/sidebar_layout.html.erb.tt",
        "test/dummy/app/views/layouts/application.html.erb",
        "test/dummy/app/views/layouts/mobile.html.erb",
        "test/dummy/app/views/layouts/devise.html.erb",
        "test/dummy/app/views/layouts/fullpage.html.erb"
      ]

      paths.each do |relative|
        content = FlatPack::Engine.root.join(relative).read

        assert_includes content, "viewport-fit=cover", relative
      end
    end
  end
end
