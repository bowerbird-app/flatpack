# frozen_string_literal: true

require "test_helper"

module FlatPack
  module AvatarGroup
    class ComponentTest < ViewComponent::TestCase
      def test_renders_avatar_group_with_items
        items = [
          {name: "John Doe"},
          {name: "Jane Smith"}
        ]
        render_inline(Component.new(items: items))

        assert_selector "div"
      end

      def test_renders_up_to_max_avatars
        items = (1..10).map { |i| {name: "User #{i}"} }
        render_inline(Component.new(items: items, max: 3))

        # Should render 3 avatars + 1 overflow
        assert_selector ".ring-2", count: 4
      end

      def test_shows_overflow_count
        items = (1..8).map { |i| {name: "User #{i}"} }
        render_inline(Component.new(items: items, max: 5))

        assert_selector "span", text: "+3"
      end

      def test_does_not_show_overflow_when_show_overflow_false
        items = (1..8).map { |i| {name: "User #{i}"} }
        render_inline(Component.new(items: items, max: 5, show_overflow: false))

        refute_selector "span", text: "+3"
      end

      def test_overflow_href_wraps_in_link
        items = (1..8).map { |i| {name: "User #{i}"} }
        render_inline(Component.new(items: items, max: 5, overflow_href: "/users"))

        assert_selector "a[href='/users']"
      end

      def test_linked_avatars_keep_full_opacity_on_hover
        items = [
          {name: "User 1", href: "/users/1"},
          {name: "User 2", href: "/users/2"}
        ]

        render_inline(Component.new(items: items))

        assert_includes page.native.to_html, "hover:!opacity-100"
      end

      def test_renders_with_overlap_styles
        items = [{name: "User 1"}]

        Component::OVERLAPS.each do |overlap, classes|
          render_inline(Component.new(items: items, overlap: overlap))

          assert_includes page.native.to_html, classes
        end
      end

      def test_hover_uses_important_z_index_while_preserving_base_stack
        items = [
          {name: "User 1"},
          {name: "User 2"}
        ]

        render_inline(Component.new(items: items))

        assert_includes page.native.to_html, "hover:!z-[999]"
        assert_includes page.native.to_html, "focus-within:!z-[999]"
        assert_includes page.native.to_html, "style=\"z-index: 2\""
        assert_includes page.native.to_html, "style=\"z-index: 1; margin-left: var(--avatar-group-overlap-md)\""
      end

      def test_passes_size_to_avatars
        items = [{name: "User"}]
        render_inline(Component.new(items: items, size: :lg))

        assert_includes page.native.to_html, "h-12"
      end

      def test_default_size_is_sm
        items = [{name: "User"}]
        render_inline(Component.new(items: items))

        assert_includes page.native.to_html, "h-8"
      end

      def test_default_overlap_is_md
        items = [{name: "User"}]
        render_inline(Component.new(items: items))

        assert_includes page.native.to_html, "-space-x-2"
      end

      def test_default_max_is_5
        items = (1..10).map { |i| {name: "User #{i}"} }
        render_inline(Component.new(items: items))

        assert_selector "span", text: "+5"
      end

      def test_raises_error_for_invalid_overlap
        assert_raises(ArgumentError) do
          Component.new(items: [], overlap: :invalid)
        end
      end

      def test_raises_error_for_non_array_items
        assert_raises(ArgumentError) do
          Component.new(items: "not an array")
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(items: [], class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(items: [], data: {testid: "avatar-group"}))

        assert_selector "div[data-testid='avatar-group']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(items: [], aria: {label: "Team members"}))

        assert_selector "div[aria-label='Team members']"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(items: [], onclick: "alert('xss')"))

        refute_selector "div[onclick]"
      end

      def test_renders_tooltip_for_each_named_avatar
        items = [
          {name: "John Doe"},
          {name: "Jane Smith"}
        ]

        render_inline(Component.new(items: items))

        assert_selector "div[data-controller='flat-pack--tooltip']", count: 2
        assert_selector "div[data-flat-pack--tooltip-placement-value='bottom']", count: 2
        assert_selector "div[role='tooltip']", text: "John Doe"
        assert_selector "div[role='tooltip']", text: "Jane Smith"
      end

      def test_does_not_render_tooltip_for_avatar_without_name_or_alt
        items = [{initials: "AB"}]

        render_inline(Component.new(items: items))

        refute_selector "div[data-controller='flat-pack--tooltip']"
      end

      def test_renders_tooltip_for_avatar_with_only_alt
        items = [{alt: "Alt Only User"}]

        render_inline(Component.new(items: items))

        assert_selector "div[data-controller='flat-pack--tooltip']", count: 1
        assert_selector "div[role='tooltip']", text: "Alt Only User"
      end

      def test_renders_overflow_tooltip_with_hidden_names
        items = [
          {initials: "A"},
          {initials: "B"},
          {name: "User Three"},
          {name: "User Four"}
        ]

        render_inline(Component.new(items: items, max: 2))

        assert_selector "span", text: "+2"
        assert_selector "div[data-controller='flat-pack--tooltip']", count: 1
        assert_selector "div[data-flat-pack--tooltip-placement-value='bottom']", count: 1
        assert_selector "div[role='tooltip'] li", count: 2
        assert_selector "div[role='tooltip'] li", text: "User Three"
        assert_selector "div[role='tooltip'] li", text: "User Four"
        assert_selector :xpath, "//li[not(ancestor::div[@role='tooltip'])]", count: 0
      end

      def test_does_not_render_overflow_tooltip_when_hidden_items_have_no_names
        items = [
          {initials: "A"},
          {initials: "B"},
          {initials: "C"},
          {initials: "D"}
        ]

        render_inline(Component.new(items: items, max: 2))

        assert_selector "span", text: "+2"
        refute_selector "div[data-controller='flat-pack--tooltip']"
      end

      def test_renders_overflow_tooltip_when_hidden_items_only_have_alt
        items = [
          {name: "Visible User"},
          {name: "Visible User 2"},
          {alt: "Hidden Alt One"},
          {alt: "Hidden Alt Two"}
        ]

        render_inline(Component.new(items: items, max: 2))

        assert_selector "span", text: "+2"
        assert_selector "div[data-controller='flat-pack--tooltip']", count: 3
        assert_selector "div[role='tooltip'] li", text: "Hidden Alt One"
        assert_selector "div[role='tooltip'] li", text: "Hidden Alt Two"
      end
    end
  end
end
