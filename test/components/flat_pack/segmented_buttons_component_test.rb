# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SegmentedButtons
    class ComponentTest < ViewComponent::TestCase
      def test_renders_segmented_buttons
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
          group.button(text: "Month")
        end

        assert_selector "div.inline-flex"
        assert_selector "button", count: 3
      end

      def test_omitted_style_uses_the_neutral_current_look_on_the_selected_button
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        assert_selector "button.fp-button-current[data-fp-style='secondary']", text: "Day"
        refute_selector "button[data-fp-style='primary']"
        refute_selector "[aria-current]"
        assert_selector "button[data-fp-style='secondary']", text: "Week"
      end

      def test_primary_style_uses_primary_on_the_selected_button
        render_inline(Component.new(style: :primary)) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        assert_selector "button[data-fp-style='primary']", text: "Day"
        assert_selector "button[data-fp-style='secondary']", text: "Week"
      end

      def test_default_style_uses_default_on_the_selected_button
        render_inline(Component.new(style: :default)) do |group|
          group.button(text: "List")
          group.button(text: "Grid", selected: true)
        end

        assert_selector "button[data-fp-style='default']", text: "Grid"
        assert_selector "button[data-fp-style='secondary']", text: "List"
      end

      def test_danger_style_uses_danger_on_the_selected_button
        render_inline(Component.new(style: :danger)) do |group|
          group.button(text: "Delete", selected: true)
          group.button(text: "Keep")
        end

        assert_selector "button[data-fp-style='danger']", text: "Delete"
        assert_selector "button[data-fp-style='secondary']", text: "Keep"
      end

      def test_unknown_style_raises_the_button_registry_message
        error = assert_raises(ArgumentError) do
          Component.new(style: :nope)
        end

        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:nope), error.message
      end

      def test_css_string_style_raises_the_button_registry_message
        error = assert_raises(ArgumentError) do
          Component.new(style: "color: red")
        end

        assert_equal FlatPack::Button::StyleRegistry.invalid_style_message(:"color: red"), error.message
      end

      def test_segment_style_raises
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |group|
            group.button(text: "Day", selected: true, style: :ghost)
          end
        end

        assert_equal "Pass style: to SegmentedButtons, not to a segment.", error.message
      end

      def test_does_not_expose_with_button_helper
        component = Component.new

        refute component.respond_to?(:with_button, true)
      end

      def test_group_size_forwards_to_buttons
        render_inline(Component.new(size: :sm)) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:sm)
      end

      def test_default_group_size_is_medium
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
        end

        assert_includes page.native.to_html, FlatPack::Button::Component::SIZES.fetch(:md)
      end

      def test_button_size_overrides_group_size
        render_inline(Component.new(size: :sm)) do |group|
          group.button(text: "Day", selected: true, size: :lg)
          group.button(text: "Week")
        end

        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:lg)
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:sm)
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_omitted_indicator_is_byte_for_byte_the_joined_group
        render_inline(Component.new) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week")
        end

        expected = +""
        expected << '<div class="inline-flex rounded-[var(--button-border-radius)] shadow-sm [&amp;&gt;*]:rounded-none '
        expected << "[&amp;&gt;*:first-child]:rounded-l-[var(--button-border-radius)] [&amp;&gt;*:last-child]:rounded-r-[var(--button-border-radius)] "
        expected << '[&amp;&gt;*]:border-r-0 [&amp;&gt;*:last-child]:border-r [&amp;&gt;*]:shadow-none">'
        expected << '<button name="button" type="button" class="inline-flex gap-2 items-center justify-center rounded-[var(--button-border-radius)] '
        expected << "font-medium cursor-pointer fp-button fp-button-flat border transition-[color,background-color,border-color,box-shadow,transform] "
        expected << "duration-[var(--duration-fast)] ease-[var(--easing-standard)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset "
        expected << "focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)] "
        expected << "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)] fp-touch-manipulation "
        expected << 'px-[var(--button-padding-x-md)] py-[var(--button-padding-y-md)] text-sm fp-button-current" data-fp-style="secondary">'
        expected << '<span class="min-w-0 max-w-full text-center truncate">Day</span></button>'
        expected << '<button name="button" type="button" class="inline-flex gap-2 items-center justify-center rounded-[var(--button-border-radius)] '
        expected << "font-medium cursor-pointer fp-button fp-button-flat border transition-[color,background-color,border-color,box-shadow,transform] "
        expected << "duration-[var(--duration-fast)] ease-[var(--easing-standard)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset "
        expected << "focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)] "
        expected << "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)] fp-touch-manipulation "
        expected << 'px-[var(--button-padding-x-md)] py-[var(--button-padding-y-md)] text-sm" data-fp-style="secondary">'
        expected << '<span class="min-w-0 max-w-full text-center truncate">Week</span></button></div>'

        assert_equal expected, rendered_content
      end

      def test_omitted_indicator_matches_the_joined_button_markup
        render_inline(Component.new(class: "host-group", data: {controller: "host"})) do |group|
          group.button(text: "Day", selected: true, data: {action: "host#pick"})
          group.button(text: "Week", href: "/week")
        end

        html = page.native.to_html
        refute_includes html, "fp-slide-indicator"
        refute_includes html, "flat-pack--slide-indicator"
        refute_includes html, "aria-pressed"
        assert_includes html, "host-group"
        assert_includes html, 'data-controller="host"'
        assert_includes html, 'data-action="host#pick"'
        assert_selector "div.inline-flex.shadow-sm"
        assert_selector "button.fp-button-current[data-fp-style='secondary']", text: "Day"
        assert_selector "a[href='/week'][data-fp-style='secondary']", text: "Week"
      end

      def test_slide_indicator_renders_the_pill_track_and_real_buttons
        render_inline(Component.new(indicator: :slide)) do |group|
          group.button(text: "Day", selected: true, data: {action: "host#pick"})
          group.button(text: "Week")
        end

        group = page.find("div.fp-slide-indicator-list")
        assert_includes group["data-controller"].to_s.split, "flat-pack--slide-indicator"
        assert_equal "pill", group["data-flat-pack--slide-indicator-kind-value"]
        assert_includes group[:class].split, "fp-pill-style"
        refute_includes group[:class].split, "fp-pill-button-slots"
        refute_includes group[:class], "shadow-sm"
        assert_selector "span.fp-slide-indicator.fp-slide-indicator--pill[aria-hidden='true']", visible: :all
        assert_selector "button.fp-button.fp-slide-indicator__item[aria-pressed='true']", text: "Day"
        assert_selector "button.fp-button.fp-slide-indicator__item[aria-pressed='false']", text: "Week"
        assert_selector "button[data-fp-style='secondary'][data-action='host#pick']", text: "Day"
        refute_selector "button.fp-button-current"
        refute_selector "[data-fp-style='primary']"
        assert_includes page.find("button", text: "Day")["data-flat-pack--slide-indicator-target"], "item"
      end

      def test_slide_indicator_primary_style_paints_the_group
        render_inline(Component.new(indicator: :slide, style: :primary, size: :sm)) do |group|
          group.button(text: "Day", selected: true)
          group.button(text: "Week", size: :lg)
        end

        group = page.find("div.fp-slide-indicator-list")
        assert_equal "primary", group["data-fp-style"]
        assert_includes group[:class].split, "fp-pill-button-slots"
        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:sm)
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:lg)
        assert_selector "button[aria-pressed='true'][data-fp-style='secondary']", text: "Day"
        refute_selector "button[data-fp-style='primary']"
      end

      def test_unknown_indicator_raises
        error = assert_raises(ArgumentError) do
          Component.new(indicator: :bounce)
        end

        assert_equal "Invalid indicator: bounce. Must be :slide", error.message
      end
    end
  end
end
