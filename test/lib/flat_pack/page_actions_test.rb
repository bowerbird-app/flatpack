# frozen_string_literal: true

require "test_helper"

module FlatPack
  class PageActionsTest < ViewComponent::TestCase
    setup do
      @actions = [
        PageAction.new(
          "New press kit",
          "/press-kits/new",
          role: :primary,
          icon: :plus,
          data: {turbo: false},
          aria: {label: "Create a press kit"}
        ),
        PageAction.new("Share", "/press-kits/share", role: :secondary, icon: :share),
        PageAction.new("Delete", "/press-kits/delete", role: :destructive, icon: :trash)
      ]
    end

    test "header maps primary to solid, secondary to subtle, and destructive to danger" do
      assert_equal(
        {primary: :primary, secondary: :secondary, destructive: :danger},
        PageActions.styles(:header)
      )
    end

    test "top nav maps primary to a subtle style and secondary to ghost" do
      assert_equal(
        {primary: :secondary, secondary: :ghost, destructive: :danger},
        PageActions.styles(:top_nav)
      )
    end

    test "mobile maps the first action with the header tokens" do
      assert_equal(
        {primary: :primary, secondary: :secondary, destructive: :danger},
        PageActions.styles(:mobile)
      )
    end

    test "a layout can override one role and the others stay" do
      map = PageActions.styles(:header, primary: :ghost)

      assert_equal :ghost, map[:primary]
      assert_equal :secondary, map[:secondary]
      assert_equal :danger, map[:destructive]
    end

    test "unknown context, role, and button style raise" do
      assert_raises(ArgumentError) { PageActions.styles(:footer) }
      assert_raises(ArgumentError) { PageActions.styles(:header, bold: :primary) }
      error = assert_raises(ArgumentError) { PageActions.styles(:header, primary: :nope) }
      assert_match(/Invalid style: nope/, error.message)
    end

    test "header renders a button group in source order with the header tokens" do
      render_context(:header)

      assert_selector ".inline-flex a[data-fp-style=primary][href='/press-kits/new'][data-turbo=false][aria-label='Create a press kit']", text: "New press kit"
      assert_selector ".inline-flex a[data-fp-style=secondary][href='/press-kits/share']", text: "Share"
      assert_selector ".inline-flex a[data-fp-style=danger][href='/press-kits/delete']", text: "Delete"
      assert_order "New press kit", "Share", "Delete"
    end

    test "top nav renders a button group with the subtle tokens" do
      render_context(:top_nav)

      assert_selector "a[data-fp-style=secondary]", text: "New press kit"
      assert_selector "a[data-fp-style=ghost]", text: "Share"
      assert_selector "a[data-fp-style=danger]", text: "Delete"
      refute_selector "a[data-fp-style=primary]"
    end

    test "mobile renders the first action and parks the rest in the overflow menu" do
      render_context(:mobile)

      assert_selector "a[data-fp-style=primary][href='/press-kits/new']", text: "New press kit"
      assert_selector "button[aria-label=More][data-fp-style=ghost]"
      assert_selector "[role=menu] a[href='/press-kits/share']", text: "Share"
      assert_selector "[role=menu] a.text-danger-text-color[href='/press-kits/delete']", text: "Delete"
      refute_selector "[role=menu] a", text: "New press kit"
    end

    test "mobile uses the mobile token for whichever role is first" do
      secondary_first = [
        PageAction.new("Share", "/press-kits/share", role: :secondary),
        PageAction.new("New press kit", "/press-kits/new", role: :primary)
      ]

      render_inline_html PageActions.render(vc_test_controller.view_context, secondary_first, :mobile)

      assert_selector "a[data-fp-style=secondary]", text: "Share"
      assert_selector "[role=menu] a[href='/press-kits/new']", text: "New press kit"
    end

    test "styles override changes the rendered token" do
      html = PageActions.render(
        vc_test_controller.view_context,
        @actions,
        :header,
        styles: {primary: :ghost}
      )
      render_inline_html html

      assert_selector "a[data-fp-style=ghost]", text: "New press kit"
      assert_selector "a[data-fp-style=secondary]", text: "Share"
      assert_selector "a[data-fp-style=danger]", text: "Delete"
    end

    test "an empty list renders nothing" do
      assert_nil PageActions.render(vc_test_controller.view_context, [], :header)
    end

    private

    def render_context(context)
      render_inline_html PageActions.render(vc_test_controller.view_context, @actions, context)
    end

    def render_inline_html(html)
      render_inline(FlatPack::Content::Component.new) { html.to_s.html_safe }
    end

    def assert_order(*labels)
      html = page.native.to_html
      indexes = labels.map { |label| html.index(label) }
      assert_equal indexes.sort, indexes
    end
  end
end
