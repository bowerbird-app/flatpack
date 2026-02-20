# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Avatar
    class ComponentTest < ViewComponent::TestCase
      def test_renders_avatar_with_image_src
        render_inline(Component.new(src: "https://example.com/avatar.jpg", alt: "User Avatar"))

        assert_selector "span img[src='https://example.com/avatar.jpg']"
        assert_selector "img[alt='User Avatar']"
        assert_selector "img[loading='lazy']"
        assert_selector "img[decoding='async']"
      end

      def test_renders_avatar_with_initials_from_name
        render_inline(Component.new(name: "John Doe"))

        assert_selector "span", text: "JD"
        assert_includes page.native.to_html, "uppercase"
      end

      def test_renders_avatar_with_explicit_initials
        render_inline(Component.new(name: "John Doe", initials: "AB"))

        assert_selector "span", text: "AB"
      end

      def test_renders_avatar_with_generic_icon_fallback
        render_inline(Component.new)

        assert_selector "svg"
      end

      def test_renders_avatar_sizes
        Component::SIZES.each do |size, classes|
          render_inline(Component.new(size: size, name: "Test"))
          
          assert_includes page.native.to_html, classes.split.first
        end
      end

      def test_renders_avatar_shapes
        Component::SHAPES.each do |shape, class_name|
          render_inline(Component.new(shape: shape, name: "Test"))
          
          assert_includes page.native.to_html, class_name
        end
      end

      def test_renders_avatar_with_status_indicator
        render_inline(Component.new(name: "User", status: :online))

        assert_selector "span[aria-hidden='true']"
        assert_includes page.native.to_html, "bg-emerald-500"
      end

      def test_renders_all_status_types
        Component::STATUS_COLORS.each do |status, _classes|
          render_inline(Component.new(name: "Test", status: status))
          
          assert_selector "span[aria-hidden='true']"
        end
      end

      def test_renders_avatar_without_status_by_default
        render_inline(Component.new(name: "User"))

        refute_selector "span[aria-hidden='true']"
      end

      def test_wraps_in_link_when_href_present
        render_inline(Component.new(name: "User", href: "/profile"))

        assert_selector "a[href='/profile']"
      end

      def test_wraps_in_span_when_no_href
        render_inline(Component.new(name: "User"))

        assert_selector "span.relative"
        refute_selector "a"
      end

      def test_default_size_is_md
        render_inline(Component.new(name: "Test"))

        assert_includes page.native.to_html, "h-10"
      end

      def test_default_shape_is_circle
        render_inline(Component.new(name: "Test"))

        assert_includes page.native.to_html, "rounded-full"
        assert_includes page.native.to_html, "aspect-square"
      end

      def test_applies_size_fallback_style_for_lg
        render_inline(Component.new(name: "Test", size: :lg))

        assert_selector "span[style*='width: 3rem'][style*='height: 3rem']"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(name: "Test", size: :invalid)
        end
      end

      def test_raises_error_for_invalid_shape
        assert_raises(ArgumentError) do
          Component.new(name: "Test", shape: :invalid)
        end
      end

      def test_raises_error_for_invalid_status
        assert_raises(ArgumentError) do
          Component.new(name: "Test", status: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(name: "Test", class: "custom-class"))

        assert_selector "span.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(name: "Test", data: {testid: "avatar"}))

        assert_selector "span[data-testid='avatar']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(name: "Test", aria: {label: "User avatar"}))

        assert_selector "span[aria-label='User avatar']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(name: "Test", id: "my-avatar"))

        assert_selector "span#my-avatar"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(name: "Test", onclick: "alert('xss')"))

        refute_selector "span[onclick]"
      end

      def test_extracts_initials_from_single_word
        render_inline(Component.new(name: "John"))

        assert_selector "span", text: "Jo"
      end

      def test_extracts_initials_from_multiple_words
        render_inline(Component.new(name: "John Michael Doe"))

        assert_selector "span", text: "JM"
      end
    end
  end
end
