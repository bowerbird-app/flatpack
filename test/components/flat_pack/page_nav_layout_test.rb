# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavLayoutTest < ViewComponent::TestCase
    test "sidebar layout draws the quiet row and folds it in a button group" do
      nominate
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-nav=default].fp-page-nav--desktop.fp-page-nav--bar a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=secondary]", text: "Share"
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=danger]", text: "Delete"
      assert_selector "[data-fp-page-nav=default] .fp-button-group-menu a", count: 3
      assert_selector "[data-fp-page-nav=default] .fp-button-group-menu__trigger[aria-label=Menu]"
      refute_selector ".fp-page-nav-menu"
      refute_selector ".fp-page-nav-nav"
      refute_selector ".fp-page-nav--floating"
      refute_selector "button[aria-label=More]"
      assert_selector ".overflow-y-auto", text: "Story"
    end

    test "sidebar layout leaves the host top nav alone" do
      nominate
      top_nav = host_top_nav("Library")
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        layout.main { "Story" }
      end

      assert_selector "header.fp-top-nav", count: 1
      assert_selector "header.fp-top-nav [data-fp-page-nav]", count: 0
      assert_selector "[data-fp-page-nav=default] .fp-button-group-menu a[data-fp-style=danger]", text: "Delete"
      refute_selector ".fp-page-nav-nav"
    end

    test "page layout draws the solid row and folds it in a button group" do
      nominate
      render_inline(PageLayout::Component.new(id: "notes")) { "Story" }

      assert_selector "#notes [data-fp-page-nav=default].fp-page-nav--desktop a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=secondary]", text: "Share"
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=danger]", text: "Delete"
      assert_selector "[data-fp-page-nav=default] .fp-button-group-menu a", count: 3
      assert_selector "main .fp-layout-column", text: "Story"
      refute_selector "header.fp-top-nav"
      refute_selector ".fp-page-nav-nav"
      refute_selector "button[aria-label=More]"
    end

    test "page layout leaves the host top nav alone" do
      nominate
      top_nav = host_top_nav("Press kit")
      render_inline(PageLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        "Story"
      end

      assert_selector "header.fp-top-nav", count: 1
      assert_selector "header.fp-top-nav [data-fp-page-nav]", count: 0
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=ghost]", count: 0
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=secondary]", text: "Share"
      refute_selector ".fp-page-nav-nav"
    end

    test "a registered component is a group child in registration order" do
      nominate_with_component
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "#publishable_quick_actions_demo", count: 1
      assert_selector ".fp-button-group-menu__panel #publishable_quick_actions_demo[data-fp-style=primary]", text: "Publish"
      refute_selector ".fp-page-nav-components"
      assert_equal ["New press kit", "Share", "Delete", "Publish"], menu_panel_labels

      nominate_with_component
      render_inline(PageLayout::Component.new) { "Story" }

      assert_selector ".fp-button-group-menu__panel #publishable_quick_actions_demo[data-fp-style=primary]", text: "Publish", count: 1
      assert_equal ["New press kit", "Share", "Delete", "Publish"], menu_panel_labels
    end

    test "a component with no links is the group" do
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      vc_test_controller.view_context.register_page_nav component: PublishableQuickActionsComponent.new, role: :secondary

      render_inline(SidebarLayout::Component.new) { |layout| layout.main { "Story" } }

      assert_selector ".fp-button-group-menu__panel #publishable_quick_actions_demo", count: 1
      assert_selector "[data-fp-page-nav=default] a", count: 0
      refute_selector ".fp-page-nav-components"
    end

    test "a registration inside the main slot is on the bar" do
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main do
          vc_test_controller.view_context.register_page_nav "New press kit", "/press-kits/new", role: :primary
          "Story"
        end
      end

      assert_selector "[data-fp-page-nav=default] a[data-fp-style=secondary]", text: "New press kit"
      assert_selector ".overflow-y-auto", text: "Story"
    end

    test "the shell draws the default bucket and leaves a named bucket alone" do
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)
      view = vc_test_controller.view_context
      view.register_page_nav "New press kit", "/press-kits/new", role: :primary
      view.register_page_nav "Notes", "/notes", role: :secondary, into: :notes

      render_inline(PageLayout::Component.new) { "Story" }

      assert_selector "a", text: "New press kit"
      refute_selector "a", text: "Notes"
    end

    test "floating pins the primary action and skips the menu" do
      nominate
      render_inline(SidebarLayout::Component.new(mobile_actions: :floating)) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-nav=floating].fp-page-nav--floating a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=floating] a.text-sm", text: "New press kit"
      refute_selector "[data-fp-page-nav=floating] a", text: "Share"
      refute_selector ".fp-button-group-menu"
      refute_selector ".fp-page-nav-menu"
      assert_selector "[data-fp-page-nav=default].fp-page-nav--pin-row a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=default] .fp-button-group a", count: 3

      render_inline(PageLayout::Component.new(mobile_actions: "floating")) { "Story" }

      assert_selector "[data-fp-page-nav=floating] a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=default] a[data-fp-style=primary]", text: "New press kit"
      refute_selector ".fp-button-group-menu"
    end

    test "floating keeps a component in the row and pins only the primary link" do
      nominate_with_component
      render_inline(SidebarLayout::Component.new(mobile_actions: :floating)) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-nav=floating] a[data-fp-style=primary]", text: "New press kit"
      refute_selector "[data-fp-page-nav=floating] #publishable_quick_actions_demo"
      refute_selector ".fp-button-group-menu"
      refute_selector ".fp-page-nav-components"
      assert_selector "[data-fp-page-nav=default].fp-page-nav--pin-row .fp-button-group #publishable_quick_actions_demo", count: 1
      assert_equal ["New press kit", "Share", "Delete", "Publish"], plain_group_labels
    end

    test "shells add no markup when the view registers nothing" do
      vc_test_controller.request.env.delete(PageNavRegistryHelper::REQUEST_KEY)

      render_inline(SidebarLayout::Component.new) { |layout| layout.main { "Story" } }
      refute_selector "[data-fp-page-nav]"
      refute_selector ".fp-page-nav-nav"

      render_inline(PageLayout::Component.new) { "Story" }
      refute_selector "[data-fp-page-nav]"
      refute_selector "[data-controller]"
    end

    test "mobile_actions rejects an unknown placement" do
      error = assert_raises(ArgumentError) { SidebarLayout::Component.new(mobile_actions: :overflow) }
      assert_match(/mobile_actions must be :menu or :floating/, error.message)
      assert_raises(ArgumentError) { PageLayout::Component.new(mobile_actions: :overflow) }
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

    def nominate_with_component
      nominate
      vc_test_controller.view_context.register_page_nav component: PublishableQuickActionsComponent.new, role: :secondary
    end

    def menu_panel_labels
      page.all("[data-fp-page-nav=default] .fp-button-group-menu__panel > *").map { |node| node.text.squish }
    end

    def plain_group_labels
      page.all("[data-fp-page-nav=default] .fp-button-group > *").map { |node| node.text.squish }
    end
  end
end
