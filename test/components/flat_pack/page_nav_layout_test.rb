# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavLayoutTest < ViewComponent::TestCase
    test "sidebar layout renders the page and does not draw registered nav" do
      nominate
      top_nav = host_top_nav("Library")
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        layout.main { "Story" }
      end

      assert_selector "header.fp-top-nav", text: "Library"
      assert_selector ".overflow-y-auto", text: "Story"
      refute_selector "a", text: "New press kit"
      refute_selector ".fp-page-nav"
      refute_selector ".fp-button-group"
    end

    test "page layout renders the column and does not draw registered nav" do
      nominate
      render_inline(PageLayout::Component.new(id: "notes")) { "Story" }

      assert_selector "#notes .fp-layout-column", text: "Story"
      refute_selector "a", text: "New press kit"
      refute_selector ".fp-page-nav"
      refute_selector ".fp-button-group"
    end

    test "a button group in the column stays in the column" do
      view = vc_test_controller.view_context
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      view.register_page_nav "New press kit", "/press-kits/new", role: :primary
      view.register_page_nav "Share", "/press-kits/share", role: :secondary

      render_inline(PageLayout::Component.new(id: "notes")) do
        view.page_nav_button_group(styles: PageNavRoleStyles::SOLID, collapse: :menu)
      end

      assert_selector "#notes .fp-layout-column .fp-button-group-menu a[data-fp-style=primary]", text: "New press kit"
      assert_selector "#notes .fp-layout-column .fp-button-group-menu a[data-fp-style=secondary]", text: "Share"
      assert_equal ["New press kit", "Share"], menu_panel_labels
      refute_selector ".fp-page-nav"
    end

    test "the shells have no page-nav placement styles" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes css, ".fp-page-nav"
      assert_not_respond_to SidebarLayout::Component.new, :actions
      assert_not_respond_to PageLayout::Component.new, :actions
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
      page.all(".fp-button-group-menu__panel > *").map { |node| node.text.squish }
    end
  end
end
