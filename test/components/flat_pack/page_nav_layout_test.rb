# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavLayoutTest < ViewComponent::TestCase
    test "the actions slot stacks above the page body" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      rule = css[/\.fp-page-nav \{.*?\n\}/m]

      refute_nil rule
      assert_includes rule, "position: relative;"
      assert_includes rule, "z-index: 1;"
    end

    test "sidebar layout places the actions slot in the bar and leaves the top nav alone" do
      top_nav = host_top_nav("Library")
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        layout.actions { "<p id=\"tools\">Tools</p>".html_safe }
        layout.main { "Story" }
      end

      assert_selector ".fp-page-nav.fp-page-nav--desktop.fp-page-nav--bar #tools", text: "Tools"
      assert_selector "header.fp-top-nav", text: "Library"
      assert_selector "header.fp-top-nav #tools", count: 0
      assert_selector ".overflow-y-auto", text: "Story"
      refute_selector ".fp-page-nav--floating"
      refute_selector ".fp-page-nav--pin-row"
    end

    test "page layout places the actions slot at the top of the column" do
      render_inline(PageLayout::Component.new(id: "notes")) do |layout|
        layout.actions { "<p id=\"tools\">Tools</p>".html_safe }
        "Story"
      end

      assert_selector "#notes .fp-layout-column > .fp-page-nav.fp-page-nav--desktop #tools", text: "Tools"
      refute_selector "#notes .fp-page-nav--bar"
      assert_selector "main .fp-layout-column", text: "Story"
      refute_selector "header.fp-top-nav"
      refute_selector ".fp-page-nav--floating"
    end

    test "an empty actions slot adds no bar" do
      view = vc_test_controller.view_context
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)

      render_inline(SidebarLayout::Component.new) do |layout|
        layout.actions { view.page_nav_button_group(styles: PageNavRoleStyles::QUIET, collapse: :menu) }
        layout.main { "Story" }
      end

      refute_selector ".fp-page-nav"
      assert_selector ".overflow-y-auto", text: "Story"

      render_inline(PageLayout::Component.new) { "Story" }

      refute_selector ".fp-page-nav"
      refute_selector "[data-controller]"
    end

    test "the shell does not draw registered nav unless the host passes it" do
      nominate
      render_inline(SidebarLayout::Component.new) { |layout| layout.main { "Story" } }

      refute_selector "a", text: "New press kit"
      refute_selector ".fp-page-nav"
      refute_selector ".fp-button-group"

      nominate
      render_inline(PageLayout::Component.new) { "Story" }

      refute_selector "a", text: "New press kit"
      refute_selector ".fp-page-nav"
    end

    test "a registration inside main is in the actions group" do
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      view = vc_test_controller.view_context

      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main do
          view.register_page_nav "New press kit", "/press-kits/new", role: :primary
          view.register_page_nav "Share", "/press-kits/share", role: :secondary
          "Story"
        end
        layout.actions do
          view.page_nav_button_group(styles: PageNavRoleStyles::QUIET, collapse: :menu)
        end
      end

      assert_selector ".fp-page-nav--bar a[data-fp-style=secondary]", text: "New press kit"
      assert_selector ".fp-page-nav--bar a[data-fp-style=secondary]", text: "Share"
      assert_selector ".overflow-y-auto", text: "Story"
      assert_equal ["New press kit", "Share"], menu_panel_labels
    end

    private

    def host_top_nav(label)
      vc_test_controller.view_context.render(FlatPack::TopNav::Component.new) { |nav| nav.left { label } }
    end

    def nominate
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      view = vc_test_controller.view_context
      view.register_page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus
      view.register_page_nav "Share", "/press-kits/share", role: :secondary, icon: :share
      view.register_page_nav "Delete", "/press-kits/delete", role: :destructive, icon: :trash
    end

    def menu_panel_labels
      page.all(".fp-page-nav .fp-button-group-menu__panel > *").map { |node| node.text.squish }
    end
  end
end
