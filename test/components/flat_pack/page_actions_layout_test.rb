# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageActionsLayoutTest < ViewComponent::TestCase
    test "sidebar layout keeps the desktop group and feeds the menu" do
      nominate
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-actions=top_nav].fp-page-actions--desktop a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=top_nav] a[data-fp-style=ghost]", text: "Share"
      assert_selector "[data-fp-page-actions=top_nav] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-actions-nav [data-fp-page-actions=menu][data-flat-pack-top-nav-collapsible=true]"
      assert_selector "[data-fp-page-actions=menu] a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=menu] a[data-fp-style=ghost]", text: "Share"
      assert_selector "[data-fp-page-actions=menu] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-actions-nav [data-flat-pack--top-nav-target=panel]", visible: :all
      refute_selector ".fp-page-actions--mobile"
      refute_selector ".fp-page-actions--floating"
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
      assert_selector "header.fp-top-nav [data-fp-page-actions=menu] a[data-fp-style=danger]", text: "Delete"
      refute_selector ".fp-page-actions-nav"
    end

    test "page layout keeps the header group and feeds the menu" do
      nominate
      render_inline(PageLayout::Component.new(id: "notes")) { "Story" }

      assert_selector "#notes [data-fp-page-actions=header].fp-page-actions--desktop a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=header] a[data-fp-style=secondary]", text: "Share"
      assert_selector "[data-fp-page-actions=header] a[data-fp-style=danger]", text: "Delete"
      assert_selector ".fp-page-actions-nav [data-fp-page-actions=menu] a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "main .fp-layout-column", text: "Story"
      refute_selector ".fp-page-actions--mobile"
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
      assert_selector "header.fp-top-nav [data-fp-page-actions=menu] a[data-fp-style=ghost]", text: "Share"
      refute_selector ".fp-page-actions-nav"
    end

    test "floating pins the primary action and skips the menu" do
      nominate
      render_inline(SidebarLayout::Component.new(mobile_actions: :floating)) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-actions=floating].fp-page-actions--floating a[data-fp-style=primary]", text: "New press kit"
      refute_selector "[data-fp-page-actions=floating] a", text: "Share"
      refute_selector "[data-fp-page-actions=menu]"
      refute_selector "button[aria-label=More]"
      assert_selector "[data-fp-page-actions=top_nav] a[data-fp-style=secondary]", text: "New press kit"

      render_inline(PageLayout::Component.new(mobile_actions: "floating")) { "Story" }

      assert_selector "[data-fp-page-actions=floating] a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=header] a[data-fp-style=primary]", text: "New press kit"
      refute_selector "[data-fp-page-actions=menu]"
    end

    test "shells add no markup when the view nominates nothing" do
      vc_test_controller.request.env.delete(PageActionHelper::REQUEST_KEY)

      render_inline(SidebarLayout::Component.new) { |layout| layout.main { "Story" } }
      refute_selector "[data-fp-page-actions]"
      refute_selector ".fp-page-actions-nav"

      render_inline(PageLayout::Component.new) { "Story" }
      refute_selector "[data-fp-page-actions]"
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
      vc_test_controller.request.env.delete(PageActionHelper::REQUEST_KEY)
      view = vc_test_controller.view_context
      view.page_action "New press kit", "/press-kits/new", role: :primary, icon: :plus
      view.page_action "Share", "/press-kits/share", role: :secondary, icon: :share
      view.page_action "Delete", "/press-kits/delete", role: :destructive, icon: :trash
    end
  end
end
