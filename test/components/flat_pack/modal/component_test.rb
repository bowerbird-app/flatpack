# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Modal
    class ComponentTest < ViewComponent::TestCase
      def test_renders_modal_with_id
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Modal content" }
        end

        assert_selector "div#my-modal"
        assert_text "Modal content"
      end

      def test_renders_modal_with_title
        render_inline(Component.new(id: "my-modal", title: "Confirm Action")) do |component|
          component.body { "Are you sure?" }
        end

        assert_selector "h2", text: "Confirm Action"
        assert_includes page.native.to_html, "fp-text-balance"
        assert_selector ".flat-pack-modal__header button[aria-label='Close']"
        assert_no_selector ".flat-pack-modal__close"
      end

      def test_renders_modal_with_header_slot
        render_inline(Component.new(id: "my-modal")) do |component|
          component.header { "Custom header" }
          component.body { "Content" }
        end

        assert_selector ".flat-pack-modal__header"
        assert_selector ".flat-pack-modal__header button[aria-label='Close']"
        assert_no_selector ".flat-pack-modal__close"
        assert_text "Custom header"
        assert_text "Content"
      end

      def test_does_not_expose_with_prefixed_slot_setters
        component = Component.new(id: "my-modal")

        refute_respond_to component, :with_header
        refute_respond_to component, :with_body
        refute_respond_to component, :with_footer
      end

      def test_renders_modal_with_footer_slot
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
          component.footer { "Footer buttons" }
        end

        assert_selector ".flat-pack-modal__footer"
        assert_text "Footer buttons"
      end

      def test_does_not_render_header_wrapper_without_title_or_header
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        assert_no_selector ".flat-pack-modal__header"
        assert_no_selector "div[aria-labelledby]"
        assert_selector ".flat-pack-modal__close"
        assert_selector ".flat-pack-modal__close button[aria-label='Close']"
      end

      def test_does_not_render_body_wrapper_without_body
        render_inline(Component.new(id: "my-modal", title: "Only header and footer")) do |component|
          component.footer { "Footer buttons" }
        end

        assert_selector ".flat-pack-modal__header"
        assert_no_selector ".flat-pack-modal__body"
        assert_selector ".flat-pack-modal__footer"
      end

      def test_does_not_render_footer_wrapper_without_footer
        render_inline(Component.new(id: "my-modal", title: "No footer")) do |component|
          component.body { "Content" }
        end

        assert_selector ".flat-pack-modal__body"
        assert_no_selector ".flat-pack-modal__footer"
      end

      def test_renders_close_button
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        assert_selector "button[aria-label='Close']"
      end

      def test_modal_has_dialog_role
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[role='dialog']"
        assert_selector "div[aria-modal='true']"
      end

      def test_modal_hidden_by_default
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        assert_selector "div.hidden"
      end

      def test_modal_has_stimulus_controller
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[data-controller='flat-pack--modal']"
      end

      def test_modal_size_small
        render_inline(Component.new(id: "my-modal", size: :sm)) do |component|
          component.body { "Content" }
        end

        assert_selector "div.max-w-sm"
      end

      def test_modal_size_medium
        render_inline(Component.new(id: "my-modal", size: :md)) do |component|
          component.body { "Content" }
        end

        assert_selector "div.max-w-xl"
      end

      def test_modal_size_large
        render_inline(Component.new(id: "my-modal", size: :lg)) do |component|
          component.body { "Content" }
        end

        assert_selector "div.max-w-2xl"
      end

      def test_raises_error_without_id
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", size: :invalid)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(id: "my-modal", class: "custom-class")) do |component|
          component.body { "Content" }
        end

        assert_selector "div.custom-class"
      end

      def test_close_on_backdrop_value
        render_inline(Component.new(id: "my-modal", close_on_backdrop: false)) do |component|
          component.body { "Content" }
        end

        assert_selector "div[data-flat-pack--modal-close-on-backdrop-value='false']"
      end

      def test_close_on_escape_value
        render_inline(Component.new(id: "my-modal", close_on_escape: false)) do |component|
          component.body { "Content" }
        end

        assert_selector "div[data-flat-pack--modal-close-on-escape-value='false']"
      end

      def test_supports_fixed_body_height
        render_inline(Component.new(id: "my-modal", body_height_mode: :fixed, body_height: "24rem")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[style*='--flatpack-modal-body-height: 24rem'][style*='height: var(--flatpack-modal-body-height)']"
      end

      def test_supports_min_body_height
        render_inline(Component.new(id: "my-modal", body_height_mode: :min, body_height: "20rem")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[style*='--flatpack-modal-body-height: 20rem'][style*='min-height: var(--flatpack-modal-body-height)']"
      end

      def test_raises_error_for_invalid_body_height_mode
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", body_height_mode: :invalid)
        end
      end

      def test_dialog_uses_duration_tokens_and_reduced_motion_scale
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Modal content" }
        end

        html = page.native.to_html
        assert_includes html, "duration-[var(--duration-slow)]"
        assert_includes html, "ease-[var(--easing-enter)]"
        assert_includes html, "motion-reduce:scale-100"
        assert_includes html, "transition-[opacity,scale]"
        refute_includes html, "transition-[opacity,transform]"
        refute_includes html, "duration-300"
        refute_includes html, "transition-all"
        refute_includes html, "ease-in-out"
      end

      def test_raises_error_when_non_auto_body_height_missing
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", body_height_mode: :fixed)
        end
      end

      def test_default_scroll_is_body
        render_inline(Component.new(id: "my-modal")) do |component|
          component.body { "Content" }
        end

        html = page.native.to_html
        assert_selector "[data-fp-modal-scroll='body']"
        assert_includes html, "fp-modal-dialog-cap"
        assert_includes html, "overflow-hidden"
        assert_includes html, "fp-modal-overlay-min"
        refute_includes html, "fp-modal-page-sticky"
        refute_includes html, "sm:my-auto"
      end

      def test_page_scroll_drops_dialog_cap_and_body_overflow
        render_inline(Component.new(id: "my-modal", scroll: :page, title: "Page scroll")) do |component|
          component.body { "Tall content" }
          component.footer { "Actions" }
        end

        html = page.native.to_html
        dialog = page.find("[data-flat-pack--modal-target='dialog']")[:class]
        body = page.find(".flat-pack-modal__body")[:class]

        assert_selector "[data-fp-modal-scroll='page']"
        refute_includes dialog, "fp-modal-dialog-cap"
        refute_includes dialog, "overflow-hidden"
        assert_includes dialog, "sm:my-auto"
        refute_includes body, "overflow-y-auto"
        assert_includes html, "fp-modal-overlay-min"
        assert_selector ".flat-pack-modal__footer"
        refute_selector ".fp-modal-sticky-footer"
      end

      def test_page_scroll_keeps_fixed_body_height_and_internal_scroll
        render_inline(Component.new(id: "my-modal", scroll: :page, body_height_mode: :fixed, body_height: "24rem")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[style*='--flatpack-modal-body-height: 24rem'][style*='height: var(--flatpack-modal-body-height)']"
        assert_includes page.find(".flat-pack-modal__body")[:class], "overflow-y-auto"
      end

      def test_page_scroll_min_body_height_does_not_cap_overflow
        render_inline(Component.new(id: "my-modal", scroll: :page, body_height_mode: :min, body_height: "20rem")) do |component|
          component.body { "Content" }
        end

        assert_selector "div[style*='min-height: var(--flatpack-modal-body-height)']"
        refute_includes page.find(".flat-pack-modal__body")[:class], "overflow-y-auto"
      end

      def test_sticky_footer_on_page_scroll
        render_inline(Component.new(id: "my-modal", scroll: :page, sticky_footer: true, title: "Pinned")) do |component|
          component.body { "Form fields" }
          component.footer { "Save" }
        end

        html = page.native.to_html
        assert_includes html, "fp-modal-page-sticky"
        assert_includes html, "fp-modal-sticky-footer"
        assert_includes html, "fp-modal-sticky-header"
      end

      def test_sticky_footer_without_footer_slot_is_a_no_op
        render_inline(Component.new(id: "my-modal", scroll: :page, sticky_footer: true, title: "No actions")) do |component|
          component.body { "Just reading" }
        end

        html = page.native.to_html
        refute_includes html, "fp-modal-page-sticky"
        refute_includes html, "fp-modal-sticky-footer"
      end

      def test_raises_error_for_invalid_scroll
        error = assert_raises(ArgumentError) do
          Component.new(id: "my-modal", scroll: :overlay)
        end

        assert_match(/Invalid scroll/, error.message)
      end

      def test_raises_error_for_sticky_footer_on_body_scroll
        error = assert_raises(ArgumentError) do
          Component.new(id: "my-modal", sticky_footer: true)
        end

        assert_match(/sticky_footer requires scroll: :page/, error.message)
      end

      def test_raises_error_for_non_boolean_sticky_footer
        error = assert_raises(ArgumentError) do
          Component.new(id: "my-modal", scroll: :page, sticky_footer: "yes")
        end

        assert_match(/sticky_footer must be true or false/, error.message)
      end

      def test_default_markup_omits_navigable_chrome
        render_inline(Component.new(id: "my-modal", title: "Confirm Action")) do |component|
          component.body { "Are you sure?" }
        end

        html = page.native.to_html
        assert_selector "div[data-controller='flat-pack--modal']"
        refute_includes html, "flat-pack--navigable"
        refute_includes html, "turbo-frame"
        refute_includes html, "data-fp-nav"
        refute_includes html, "gallery-editor-screen"
        refute_includes html, "data-flat-pack--navigable"
        refute_selector "[data-fp-screen]"
        assert_no_selector "button[aria-label='Back']"
      end

      def test_navigable_false_matches_omitted_navigable
        render_inline(Component.new(id: "my-modal", title: "Same")) do |modal|
          modal.body { "Body" }
        end
        omitted = page.native.to_html.dup

        render_inline(Component.new(id: "my-modal", title: "Same", navigable: false)) do |modal|
          modal.body { "Body" }
        end

        assert_equal omitted, page.native.to_html
      end

      def test_navigable_markup_uses_turbo_frame_and_managed_header
        render_inline(Component.new(id: "gallery-editor", title: "Gallery", navigable: true, src: "/demo/modals/gallery_editor"))

        assert_selector "div[data-controller='flat-pack--modal flat-pack--navigable']"
        assert_selector "[data-flat-pack--navigable-src-value='/demo/modals/gallery_editor']"
        assert_selector "turbo-frame#gallery-editor-screen[src='/demo/modals/gallery_editor'][loading='lazy']"
        assert_selector "[data-flat-pack--navigable-target='frame']"
        assert_selector "[data-flat-pack--navigable-target='title']", text: "Gallery"
        assert_selector "[data-flat-pack--navigable-target='backButton'][hidden][data-fp-nav='back']", visible: :all
        assert_selector "[data-flat-pack--navigable-target='headerActions']"
        assert_selector "[data-flat-pack--navigable-target='footer'][hidden]", visible: :all
        assert_selector "[data-flat-pack--navigable-target='loading'][hidden]", visible: :all
        assert_selector "[data-flat-pack--navigable-target='error'][hidden]", visible: :all
        assert_selector "[data-flat-pack--navigable-target='liveRegion'][aria-live='polite']", visible: :all
        assert_selector "button[aria-label='Close']"
        assert_includes page.native.to_html, "Try again"
      end

      def test_navigable_keeps_size_scroll_and_sticky_footer
        render_inline(Component.new(
          id: "gallery-editor",
          title: "Gallery",
          navigable: true,
          src: "/demo/modals/gallery_editor",
          size: :lg,
          scroll: :page,
          sticky_footer: true
        ))

        assert_selector "div.max-w-2xl"
        assert_selector "[data-fp-modal-scroll='page']"
        assert_includes page.native.to_html, "fp-modal-page-sticky"
        assert_includes page.native.to_html, "fp-modal-sticky-footer"
      end

      def test_navigable_requires_src_and_rejects_body_or_header_slots
        error = assert_raises(ArgumentError) do
          Component.new(id: "gallery-editor", navigable: true)
        end
        assert_match(/src is required/, error.message)

        error = assert_raises(ArgumentError) do
          Component.new(id: "gallery-editor", src: "/gallery")
        end
        assert_match(/src is only valid when navigable/, error.message)

        error = assert_raises(ArgumentError) do
          Component.new(id: "gallery-editor", navigable: "yes", src: "/gallery")
        end
        assert_match(/navigable must be true or false/, error.message)

        error = assert_raises(ArgumentError) do
          render_inline(Component.new(id: "gallery-editor", navigable: true, src: "/gallery")) do |modal|
            modal.body { "nope" }
          end
        end
        assert_match(/body slot is not used/, error.message)

        error = assert_raises(ArgumentError) do
          render_inline(Component.new(id: "gallery-editor", navigable: true, src: "/gallery")) do |modal|
            modal.header { "nope" }
          end
        end
        assert_match(/header slot is not used/, error.message)
      end

      def test_navigable_rejects_unsafe_src
        error = assert_raises(ArgumentError) do
          Component.new(id: "gallery-editor", navigable: true, src: "javascript:alert(1)")
        end
        assert_match(/Unsafe src/, error.message)
      end
    end
  end
end
