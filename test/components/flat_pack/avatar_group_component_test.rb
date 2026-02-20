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
        assert_selector "div > div", count: 4
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

      def test_renders_with_overlap_styles
        items = [{name: "User 1"}]
        
        Component::OVERLAPS.each do |overlap, classes|
          render_inline(Component.new(items: items, overlap: overlap))
          
          assert_includes page.native.to_html, classes
        end
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
    end
  end
end
