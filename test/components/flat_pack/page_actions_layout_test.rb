# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageActionsLayoutTest < ViewComponent::TestCase
    test "sidebar layout places top nav actions and a mobile overflow" do
      nominate
      render_inline(SidebarLayout::Component.new) do |layout|
        layout.main { "Story" }
      end

      assert_selector "[data-fp-page-actions=top_nav].fp-page-actions--desktop a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=top_nav] a[data-fp-style=ghost]", text: "Share"
      assert_selector "[data-fp-page-actions=top_nav] a[data-fp-style=danger]", text: "Delete"
      assert_selector "[data-fp-page-actions=mobile].fp-page-actions--mobile a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=mobile] button[aria-label=More]"
      assert_selector "[data-fp-page-actions=mobile] [role=menu] a", text: "Delete"
      assert_selector ".overflow-y-auto", text: "Story"
    end

    test "page layout places header actions and a mobile overflow" do
      nominate
      render_inline(PageLayout::Component.new(id: "notes")) { "Story" }

      assert_selector "#notes [data-fp-page-actions=header].fp-page-actions--desktop a[data-fp-style=primary]", text: "New press kit"
      assert_selector "[data-fp-page-actions=header] a[data-fp-style=secondary]", text: "Share"
      assert_selector "[data-fp-page-actions=header] a[data-fp-style=danger]", text: "Delete"
      assert_selector "[data-fp-page-actions=mobile] a[data-fp-style=primary]", text: "New press kit"
      assert_selector "main .fp-layout-column", text: "Story"
    end

    test "shells add no markup when the view nominates nothing" do
      vc_test_controller.request.env.delete(PageActionHelper::REQUEST_KEY)

      render_inline(SidebarLayout::Component.new) { |layout| layout.main { "Story" } }
      refute_selector "[data-fp-page-actions]"

      render_inline(PageLayout::Component.new) { "Story" }
      refute_selector "[data-fp-page-actions]"
      refute_selector "[data-controller]"
    end

    private

    def nominate
      vc_test_controller.request.env.delete(PageActionHelper::REQUEST_KEY)
      view = vc_test_controller.view_context
      view.page_action "New press kit", "/press-kits/new", role: :primary, icon: :plus
      view.page_action "Share", "/press-kits/share", role: :secondary, icon: :share
      view.page_action "Delete", "/press-kits/delete", role: :destructive, icon: :trash
    end
  end
end
