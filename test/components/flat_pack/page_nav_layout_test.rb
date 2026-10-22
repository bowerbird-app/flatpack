# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageNavLayoutTest < ViewComponent::TestCase
    setup do
      @previous_styles = FlatPack.configuration.page_nav_styles
    end

    teardown do
      FlatPack.configuration.page_nav_styles = @previous_styles
    end

    test "sidebar layout keeps the desktop group and feeds the menu" do
      nominate
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-nav=top_nav].fp-page-nav--desktop a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=top_nav] a[data-fp-style=ghost]", text: "Share"
      assert_selector "[data-fp-page-nav=top_nav] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-nav-nav [data-fp-page-nav=menu][data-flat-pack-top-nav-collapsible=true]"
      assert_selector "[data-fp-page-nav=menu] a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=menu] a[data-fp-style=ghost]", text: "Share"
      assert_selector "[data-fp-page-nav=menu] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-nav-nav [data-flat-pack--top-nav-target=panel]", visible: :all
      refute_selector ".fp-page-nav--floating"
      refute_selector "button[aria-label=More]"
      assert_selector ".overflow-y-auto", text: "Story"
    end

    test "sidebar layout puts menu rows in the host top nav" do
      nominate
      top_nav = host_top_nav("Library")
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        layout.main { "Story" }
      end

      assert_selector "header.fp-top-nav", count: 1
      assert_selector "header.fp-top-nav [data-fp-page-nav=menu] a[data-fp-style=danger]", text: "Delete"
      refute_selector ".fp-page-nav-nav"
    end

    test "page layout keeps the header group and feeds the menu" do
      nominate
      render_inline(PageLayout::Component.new(id: "notes")) { "Story" }

      assert_selector "#notes [data-fp-page-nav=header].fp-page-nav--desktop a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=header] a[data-fp-style=secondary]", text: "Share"
      assert_selector "[data-fp-page-nav=header] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-nav-nav [data-fp-page-nav=menu] a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "main .fp-layout-column", text: "Story"
      refute_selector "button[aria-label=More]"
    end

    test "page layout puts menu rows in the host top nav" do
      nominate
      top_nav = host_top_nav("Press kit")
      render_inline(PageLayout::Component.new) do |layout|
        layout.top_nav { top_nav }
        "Story"
      end

      assert_selector "header.fp-top-nav", count: 1
      assert_selector "header.fp-top-nav [data-fp-page-nav=menu] a[data-fp-style=ghost]", text: "Share"
      refute_selector ".fp-page-nav-nav"
    end

    test "a registered component renders once and stays out of the phone menu" do
      nominate_with_component
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "#publishable_quick_actions_demo", count: 1
      assert_selector ".fp-page-nav-components #publishable_quick_actions_demo", count: 1
      assert_selector "[data-fp-page-nav=menu] #publishable_quick_actions_demo", count: 0
      refute_selector "#publishable_quick_actions_demo[data-fp-style]"

      nominate_with_component
      render_inline(PageLayout::Component.new) { "Story" }

      assert_selector "#publishable_quick_actions_demo", count: 1
      assert_selector "[data-fp-page-nav=menu] #publishable_quick_actions_demo", count: 0
    end

    test "floating pins the primary action and skips the menu" do
      nominate
      render_inline(SidebarLayout::Component.new(mobile_actions: :floating)) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-nav=floating].fp-page-nav--floating a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=floating] a.text-sm", text: "New press kit"
      refute_selector "[data-fp-page-nav=floating] a", text: "Share"
      refute_selector "[data-fp-page-nav=menu]"
      refute_selector "button[aria-label=More]"
      assert_selector "[data-fp-page-nav=top_nav] a[data-fp-style=secondary]", text: "New press kit"

      render_inline(PageLayout::Component.new(mobile_actions: "floating")) { "Story" }

      assert_selector "[data-fp-page-nav=floating] a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-nav=header] a[data-fp-style=primary]", text: "New press kit"
      refute_selector "[data-fp-page-nav=menu]"
    end

    test "the host map changes the shell buttons" do
      FlatPack.configuration.page_nav_styles = {
        header: {primary: {style: :ghost}}
      }
      nominate
      render_inline(PageLayout::Component.new) { "Story" }

      assert_selector "[data-fp-page-nav=header] a[data-fp-style=ghost]", text: "New press kit"
      assert_selector "[data-fp-page-nav=header] a[data-fp-style=secondary]", text: "Share"
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
      view.page_nav "New press kit", "/press-kits/new", role: :primary, icon: :plus
      view.page_nav "Share", "/press-kits/share", role: :secondary, icon: :share
      view.page_nav "Delete", "/press-kits/delete", role: :destructive, icon: :trash
    end

    def nominate_with_component
      nominate
      vc_test_controller.view_context.page_nav component: PublishableQuickActionsComponent.new, role: :secondary
    end
  end
end
