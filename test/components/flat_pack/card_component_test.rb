# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Card
    class ComponentTest < ViewComponent::TestCase
      # Basic Card Tests
      def test_renders_basic_card
        render_inline(Component.new)
        assert_selector "div"
      end

      def test_renders_card_with_content
        render_inline(Component.new) do
          "Card content"
        end
        assert_text "Card content"
      end

      # Style Tests
      def test_renders_with_style_default
        render_inline(Component.new(style: :default))
        assert_includes page.native.to_html, "bg-[var(--color-background)]"
        assert_includes page.native.to_html, "border border-[var(--color-border)]"
      end

      def test_renders_with_style_elevated
        render_inline(Component.new(style: :elevated))
        assert_includes page.native.to_html, "shadow-md"
      end

      def test_renders_with_style_outlined
        render_inline(Component.new(style: :outlined))
        assert_includes page.native.to_html, "border-2"
      end

      def test_renders_with_style_flat
        render_inline(Component.new(style: :flat))
        assert_includes page.native.to_html, "bg-[var(--color-muted)]"
      end

      def test_renders_with_style_interactive
        render_inline(Component.new(style: :interactive))
        assert_includes page.native.to_html, "hover:shadow-md"
        assert_includes page.native.to_html, "hover:border-[var(--color-primary)]"
        assert_includes page.native.to_html, "cursor-pointer"
      end

      def test_validates_style
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(style: :invalid))
        end
        assert_includes error.message, "Invalid style"
      end

      # Padding Tests
      def test_renders_with_padding_none
        render_inline(Component.new(padding: :none))
        refute_includes page.native.to_html, "p-4"
        refute_includes page.native.to_html, "p-6"
        refute_includes page.native.to_html, "p-8"
      end

      def test_renders_with_padding_sm
        render_inline(Component.new(padding: :sm))
        assert_includes page.native.to_html, "p-4"
      end

      def test_renders_with_padding_md
        render_inline(Component.new(padding: :md))
        assert_includes page.native.to_html, "p-6"
      end

      def test_renders_with_padding_lg
        render_inline(Component.new(padding: :lg))
        assert_includes page.native.to_html, "p-8"
      end

      def test_validates_padding
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(padding: :invalid))
        end
        assert_includes error.message, "Invalid padding"
      end

      # Clickable Card Tests
      def test_renders_clickable_card_with_href
        render_inline(Component.new(clickable: true, href: "/posts/1")) do
          "Clickable card"
        end
        assert_selector "a[href='/posts/1']", text: "Clickable card"
      end

      def test_clickable_card_wraps_in_link
        render_inline(Component.new(clickable: true, href: "/posts/1"))
        assert_selector "a"
      end

      def test_non_clickable_card_renders_as_div
        render_inline(Component.new(clickable: false))
        assert_selector "div"
        assert_no_selector "a"
      end

      def test_clickable_without_href_renders_as_div
        render_inline(Component.new(clickable: true))
        assert_selector "div"
        assert_no_selector "a"
      end

      def test_validates_href_url_safety
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(clickable: true, href: "javascript:alert('XSS')"))
        end
        assert_includes error.message, "Unsafe URL"
      end

      # Slot Tests
      def test_renders_with_header_slot
        render_inline(Component.new) do |component|
          component.header do
            "<h3>Card Title</h3>".html_safe
          end
        end
        assert_selector "h3", text: "Card Title"
      end

      def test_renders_with_body_slot
        render_inline(Component.new) do |component|
          component.body do
            "<p>Card body content</p>".html_safe
          end
        end
        assert_selector "p", text: "Card body content"
      end

      def test_renders_with_footer_slot
        render_inline(Component.new) do |component|
          component.footer do
            "<button>Action</button>".html_safe
          end
        end
        assert_selector "button", text: "Action"
      end

      def test_renders_with_media_slot
        render_inline(Component.new) do |component|
          component.media do
            "<img src='test.jpg' alt='Test'>".html_safe
          end
        end
        assert_selector "img[src='test.jpg']"
      end

      def test_renders_with_all_slots
        render_inline(Component.new) do |component|
          component.media { "<img src='test.jpg'>".html_safe }
          component.header { "<h3>Title</h3>".html_safe }
          component.body { "<p>Content</p>".html_safe }
          component.footer { "<button>Action</button>".html_safe }
        end
        assert_selector "img"
        assert_selector "h3", text: "Title"
        assert_selector "p", text: "Content"
        assert_selector "button", text: "Action"
      end

      def test_empty_card_without_slots
        render_inline(Component.new)
        assert_selector "div"
      end

      # Header Component Tests
      def test_header_component_renders
        render_inline(HeaderComponent.new) { "Header content" }
        assert_selector "div", text: "Header content"
      end

      def test_header_with_divider
        render_inline(HeaderComponent.new(divider: true)) { "Header" }
        assert_includes page.native.to_html, "border-b"
        assert_includes page.native.to_html, "border-[var(--color-border)]"
      end

      def test_header_without_divider
        render_inline(HeaderComponent.new(divider: false)) { "Header" }
        refute_includes page.native.to_html, "border-b"
      end

      def test_header_default_divider_is_true
        render_inline(HeaderComponent.new) { "Header" }
        assert_includes page.native.to_html, "border-b"
      end

      def test_header_has_padding_classes
        render_inline(HeaderComponent.new) { "Header" }
        assert_includes page.native.to_html, "px-6 py-4"
      end

      # Body Component Tests
      def test_body_component_renders
        render_inline(BodyComponent.new) { "Body content" }
        assert_selector "div", text: "Body content"
      end

      def test_body_has_padding_classes
        render_inline(BodyComponent.new) { "Body" }
        assert_includes page.native.to_html, "px-6 py-4"
      end

      # Footer Component Tests
      def test_footer_component_renders
        render_inline(FooterComponent.new) { "Footer content" }
        assert_selector "div", text: "Footer content"
      end

      def test_footer_with_divider
        render_inline(FooterComponent.new(divider: true)) { "Footer" }
        assert_includes page.native.to_html, "border-t"
        assert_includes page.native.to_html, "border-[var(--color-border)]"
      end

      def test_footer_without_divider
        render_inline(FooterComponent.new(divider: false)) { "Footer" }
        refute_includes page.native.to_html, "border-t"
      end

      def test_footer_default_divider_is_true
        render_inline(FooterComponent.new) { "Footer" }
        assert_includes page.native.to_html, "border-t"
      end

      def test_footer_has_padding_classes
        render_inline(FooterComponent.new) { "Footer" }
        assert_includes page.native.to_html, "px-6 py-4"
      end

      # Media Component Tests
      def test_media_component_renders
        render_inline(MediaComponent.new) { "<img src='test.jpg'>".html_safe }
        assert_selector "img"
      end

      def test_media_has_overflow_hidden
        render_inline(MediaComponent.new) { "Media" }
        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_media_with_aspect_ratio_16_9
        render_inline(MediaComponent.new(aspect_ratio: "16/9")) { "Media" }
        assert_includes page.native.to_html, "aspect-[16/9]"
      end

      def test_media_with_aspect_ratio_4_3
        render_inline(MediaComponent.new(aspect_ratio: "4/3")) { "Media" }
        assert_includes page.native.to_html, "aspect-[4/3]"
      end

      def test_media_with_aspect_ratio_1_1
        render_inline(MediaComponent.new(aspect_ratio: "1/1")) { "Media" }
        assert_includes page.native.to_html, "aspect-square"
      end

      def test_media_with_custom_aspect_ratio
        render_inline(MediaComponent.new(aspect_ratio: "21/9")) { "Media" }
        assert_includes page.native.to_html, "aspect-[21/9]"
      end

      def test_media_without_aspect_ratio
        render_inline(MediaComponent.new) { "Media" }
        refute_includes page.native.to_html, "aspect-"
      end

      # System Arguments Tests
      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))
        assert_includes page.native.to_html, "custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {controller: "card"}))
        assert_selector "div[data-controller='card']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(aria: {label: "Card label"}))
        assert_selector "div[aria-label='Card label']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(id: "custom-card"))
        assert_selector "div#custom-card"
      end

      # Integration Tests
      def test_interactive_card_has_correct_classes
        render_inline(Component.new(style: :interactive))
        html = page.native.to_html
        assert_includes html, "cursor-pointer"
        assert_includes html, "hover:shadow-md"
        assert_includes html, "transition-all"
      end

      def test_clickable_interactive_card_applies_to_link
        render_inline(Component.new(style: :interactive, clickable: true, href: "/test"))
        assert_selector "a[href='/test']"
        html = page.native.to_html
        assert_includes html, "cursor-pointer"
      end

      def test_card_has_rounded_corners
        render_inline(Component.new)
        assert_includes page.native.to_html, "rounded-[var(--radius-lg)]"
      end

      def test_card_has_overflow_hidden
        render_inline(Component.new)
        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_slots_override_padding_when_used
        render_inline(Component.new(padding: :lg)) do |component|
          component.body { "Content" }
        end
        # Body has its own padding (px-6 py-4), main card padding applies to container
        assert_includes page.native.to_html, "p-8"
        assert_includes page.native.to_html, "px-6 py-4"
      end

      def test_content_appears_when_no_slots_used
        render_inline(Component.new) { "Direct content" }
        assert_text "Direct content"
      end

      def test_content_not_rendered_when_slots_used
        render_inline(Component.new) do |component|
          component.body { "Body content" }
          "This should not appear"
        end
        assert_text "Body content"
        refute_text "This should not appear"
      end

      def test_multiple_style_variants_apply_correctly
        [:default, :elevated, :outlined, :flat, :interactive].each do |style|
          render_inline(Component.new(style: style))
          # Each style should render without errors
          assert_selector "div"
        end
      end

      def test_sanitizes_dangerous_attributes
        # This should not raise an error because FlatPack::AttributeSanitizer handles it
        render_inline(Component.new(onclick: "alert('xss')"))
        assert_selector "div"
        # onclick should be filtered out by sanitizer
        refute_includes page.native.to_html, "onclick"
      end

      def test_relative_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "/posts/1"))
        assert_selector "a[href='/posts/1']"
      end

      def test_http_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "http://example.com"))
        assert_selector "a[href='http://example.com']"
      end

      def test_https_urls_are_allowed
        render_inline(Component.new(clickable: true, href: "https://example.com"))
        assert_selector "a[href='https://example.com']"
      end
    end
  end
end
