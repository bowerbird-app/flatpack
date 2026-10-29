# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class ComponentTest < ViewComponent::TestCase
      def test_renders_button_with_primary_scheme
        render_inline(Component.new(text: "Click me", style: :primary))

        assert_selector "button", text: "Click me"
        assert_selector "button[type='button']"
      end

      def test_renders_button_with_secondary_scheme
        render_inline(Component.new(text: "Secondary", style: :secondary))

        assert_selector "button", text: "Secondary"
      end

      def test_renders_button_with_ghost_scheme
        render_inline(Component.new(text: "Ghost", style: :ghost))

        assert_selector "button", text: "Ghost"
      end

      def test_renders_link_when_url_provided
        render_inline(Component.new(text: "Link", href: "/path"))

        assert_selector "a[href='/path']", text: "Link"
      end

      def test_renders_link_with_method
        render_inline(Component.new(text: "Delete", href: "/path", method: :delete))

        assert_selector "a[href='/path']", text: "Delete"
      end

      def test_raises_error_for_invalid_scheme
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", style: :invalid)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(text: "Custom", class: "custom-class"))

        assert_selector "button.custom-class"
      end

      def test_custom_radius_class_overrides_default_radius
        render_inline(Component.new(text: "Rounded", class: "rounded-xl"))

        assert_selector "button.rounded-xl"
        refute_includes page.native.to_html, "rounded-[var(--button-border-radius)]"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(text: "Data", data: {action: "click"}))

        assert_selector "button[data-action='click']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(text: "Aria", aria: {label: "Custom label"}))

        assert_selector "button[aria-label='Custom label']"
      end

      def test_default_scheme_is_default
        component = Component.new(text: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
        assert_selector "button[data-fp-style='default']"
        assert_selector "button.fp-button-raised"
      end

      def test_default_size_is_md
        component = Component.new(text: "Default")
        render_inline(component)

        assert_selector "button", text: "Default"
        # The rendered HTML should contain the md size classes
        assert_includes page.native.to_html, "px-[var(--button-padding-x-md)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-md)]"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_small_size
        render_inline(Component.new(text: "Small", size: :sm))

        assert_selector "button", text: "Small"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-sm)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-sm)]"
        assert_includes page.native.to_html, "text-xs"
      end

      def test_renders_button_with_medium_size
        render_inline(Component.new(text: "Medium", size: :md))

        assert_selector "button", text: "Medium"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-md)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-md)]"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_button_with_large_size
        render_inline(Component.new(text: "Large", size: :lg))

        assert_selector "button", text: "Large"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-lg)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-lg)]"
        assert_includes page.native.to_html, "text-base"
      end

      def test_renders_link_with_size
        render_inline(Component.new(text: "Link", href: "/path", size: :lg))

        assert_selector "a[href='/path']", text: "Link"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-lg)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-lg)]"
        assert_includes page.native.to_html, "text-base"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", size: :xl)
        end
      end

      def test_renders_link_with_target_blank
        render_inline(Component.new(text: "External", href: "https://example.com", target: "_blank"))

        assert_selector "a[href='https://example.com'][target='_blank']", text: "External"
        assert_selector "a[rel='noopener noreferrer']"
      end

      def test_renders_link_with_target_self
        render_inline(Component.new(text: "Same Tab", href: "/path", target: "_self"))

        assert_selector "a[href='/path'][target='_self']", text: "Same Tab"
      end

      def test_link_without_target_has_no_target_attribute
        render_inline(Component.new(text: "Link", href: "/path"))

        assert_selector "a[href='/path']", text: "Link"
        refute_selector "a[target]"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(text: "With ID", id: "my-button"))

        assert_selector "button#my-button", text: "With ID"
      end

      def test_accepts_id_attribute_on_link
        render_inline(Component.new(text: "Link ID", href: "/path", id: "my-link"))

        assert_selector "a#my-link[href='/path']", text: "Link ID"
      end

      def test_renders_success_scheme
        render_inline(Component.new(text: "Success", style: :success))

        assert_selector "button", text: "Success"
      end

      def test_renders_warning_scheme
        render_inline(Component.new(text: "Warning", style: :warning))

        assert_selector "button", text: "Warning"
      end

      def test_renders_danger_scheme
        render_inline(Component.new(text: "Danger", style: :danger))

        assert_selector "button", text: "Danger"
      end

      def test_renders_icon_only_button
        render_inline(Component.new(icon: "search", icon_only: true, aria: {label: "Search"}))

        assert_selector "button[aria-label='Search']"
        refute_selector "button span"
        assert_includes page.native.to_html, "fp-hit-target"
      end

      def test_applies_touch_manipulation
        render_inline(Component.new(text: "Save"))

        assert_includes page.native.to_html, "fp-touch-manipulation"
      end

      def test_icon_only_text_becomes_aria_label_and_is_not_visible
        render_inline(Component.new(icon: "search", icon_only: true, text: "Search"))

        assert_selector "button[aria-label='Search']"
        refute_selector "button span", text: "Search"
      end

      def test_icon_only_keeps_host_aria_label
        render_inline(Component.new(icon: "search", icon_only: true, text: "Find", aria: {label: "Open search", pressed: true}))

        assert_selector "button[aria-label='Open search'][aria-pressed='true']"
        refute_selector "button[aria-label='Find']"
      end

      def test_icon_only_without_accessible_name_raises
        error = assert_raises(ArgumentError) do
          Component.new(icon: "search", icon_only: true)
        end
        assert_match(/accessible name/, error.message)
      end

      def test_renders_button_with_icon_and_label
        render_inline(Component.new(text: "Search", icon: "search"))

        assert_selector "button", text: "Search"
      end

      def test_renders_loading_button
        render_inline(Component.new(text: "Save", loading: true))

        assert_selector "button[disabled]"
        assert_includes page.native.to_html, "fp-spinner"
        refute_includes page.native.to_html, "motion-reduce:animate-none"
        assert_selector "button", text: "Loading"
      end

      def test_renders_loading_icon_only_button
        render_inline(Component.new(icon: "search", icon_only: true, loading: true, aria: {label: "Search"}))

        assert_selector "button[disabled][aria-label='Search'][aria-busy='true']"
        assert_includes page.native.to_html, "fp-spinner"
        refute_includes page.native.to_html, "motion-reduce:animate-none"
        refute_selector "button", text: "Loading"
      end

      def test_raises_error_for_button_without_content
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_sanitizes_javascript_url
        error = assert_raises(ArgumentError) do
          Component.new(text: "Click", href: "javascript:alert('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_data_url
        error = assert_raises(ArgumentError) do
          Component.new(text: "Click", href: "data:text/html,<script>alert('xss')</script>")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_sanitizes_vbscript_url
        error = assert_raises(ArgumentError) do
          Component.new(text: "Click", href: "vbscript:msgbox('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_allows_safe_urls
        render_inline(Component.new(text: "Click", href: "https://example.com"))
        assert_selector "a[href='https://example.com']", text: "Click"
      end

      def test_allows_relative_urls
        render_inline(Component.new(text: "Click", href: "/path/to/page"))
        assert_selector "a[href='/path/to/page']", text: "Click"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(text: "Click", onclick: "alert('xss')"))
        refute_selector "button[onclick]"
      end

      def test_default_type_is_button
        render_inline(Component.new(text: "Click me"))

        assert_selector "button[type='button']", text: "Click me"
      end

      def test_renders_submit_type_button
        render_inline(Component.new(text: "Submit", type: "submit"))

        assert_selector "button[type='submit']", text: "Submit"
      end

      def test_renders_reset_type_button
        render_inline(Component.new(text: "Reset", type: "reset"))

        assert_selector "button[type='reset']", text: "Reset"
      end

      def test_link_does_not_have_type_attribute
        render_inline(Component.new(text: "Link", href: "/path", type: "submit"))

        assert_selector "a[href='/path']", text: "Link"
        refute_selector "a[type]"
      end

      def test_renders_button_with_cursor_pointer_class
        render_inline(Component.new(text: "Click me"))

        assert_selector "button.cursor-pointer"
      end

      def test_renders_link_with_cursor_pointer_class
        render_inline(Component.new(text: "Link", href: "/path"))

        assert_selector "a.cursor-pointer"
      end

      def test_submit_button_with_different_styles
        render_inline(Component.new(text: "Submit Primary", type: "submit", style: :primary))
        assert_selector "button[type='submit']", text: "Submit Primary"

        render_inline(Component.new(text: "Submit Success", type: "submit", style: :success))
        assert_selector "button[type='submit']", text: "Submit Success"

        render_inline(Component.new(text: "Submit Warning", type: "submit", style: :warning))
        assert_selector "button[type='submit']", text: "Submit Warning"
      end

      def test_submit_button_with_different_sizes
        render_inline(Component.new(text: "Submit Small", type: "submit", size: :sm))
        assert_selector "button[type='submit']", text: "Submit Small"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-sm)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-sm)]"
        assert_includes page.native.to_html, "text-xs"

        render_inline(Component.new(text: "Submit Large", type: "submit", size: :lg))
        assert_selector "button[type='submit']", text: "Submit Large"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-lg)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-lg)]"
        assert_includes page.native.to_html, "text-base"
      end

      def test_submit_button_with_icon
        render_inline(Component.new(text: "Submit", type: "submit", icon: "check"))
        assert_selector "button[type='submit']", text: "Submit"
      end

      def test_submit_button_with_loading_state
        render_inline(Component.new(text: "Submitting", type: "submit", loading: true))
        assert_selector "button[type='submit'][disabled]"
        assert_includes page.native.to_html, "fp-spinner"
        refute_includes page.native.to_html, "motion-reduce:animate-none"
        assert_selector "button", text: "Loading"
      end

      def test_submit_button_with_name_and_value
        render_inline(Component.new(text: "Publish", type: "submit", name: "action", value: "publish"))
        assert_selector "button[type='submit'][name='action'][value='publish']", text: "Publish"
      end

      def test_submit_button_with_custom_classes
        render_inline(Component.new(text: "Submit", type: "submit", class: "w-full"))
        assert_selector "button[type='submit'].w-full", text: "Submit"
      end

      def test_submit_button_disabled
        render_inline(Component.new(text: "Submit", type: "submit", disabled: true))
        assert_selector "button[type='submit'][disabled]", text: "Submit"
        html = page.native.to_html
        assert_includes html, "pointer-events-none"
        assert_includes html, "opacity-[var(--button-disabled-opacity)]"
        refute_includes html, "fp-spinner"
      end

      def test_disabled_button_sets_the_disabled_attribute_without_loading
        render_inline(Component.new(text: "Save", style: :primary, disabled: true))

        assert_selector "button[disabled][type='button']", text: "Save"
        refute_selector "button[aria-busy]"
        html = page.native.to_html
        assert_includes html, "pointer-events-none"
        assert_includes html, "disabled:opacity-[var(--button-disabled-opacity)]"
        refute_includes html, "fp-spinner"
        refute_selector "button", text: "Loading"
      end

      def test_disabled_link_keeps_href
        render_inline(Component.new(text: "Open", href: "/path", method: :delete, target: "_blank", disabled: true))

        assert_selector "a[href='/path'][target='_blank'][rel='noopener noreferrer']", text: "Open"
        refute_selector "a[disabled]"
        refute_selector "a[aria-disabled]"
        refute_selector "a[tabindex]"
      end

      def test_enabled_link_keeps_href_and_is_not_aria_disabled
        render_inline(Component.new(text: "Open", href: "/path"))

        assert_selector "a[href='/path']", text: "Open"
        refute_selector "a[aria-disabled]"
        refute_selector "a[tabindex]"
        html = page.native.to_html
        assert_includes html, "disabled:pointer-events-none"
        refute_includes html.gsub("disabled:pointer-events-none", ""), "pointer-events-none"
      end

      def test_loading_still_disables_when_disabled_is_omitted
        render_inline(Component.new(text: "Save", loading: true))

        assert_selector "button[disabled]", text: "Loading"
        assert_includes page.native.to_html, "fp-spinner"
      end

      def test_disabled_and_loading_keep_the_spinner
        render_inline(Component.new(text: "Save", disabled: true, loading: true))

        assert_selector "button[disabled]", text: "Loading"
        assert_includes page.native.to_html, "fp-spinner"
      end

      def test_disabled_nil_false_and_true_are_accepted
        [nil, false, true].each do |disabled|
          Component.new(text: "Save", disabled: disabled)
        end
      end

      def test_disabled_nil_omits_the_disabled_attribute
        render_inline(Component.new(text: "Save", disabled: nil))

        assert_selector "button[type='button']", text: "Save"
        refute_selector "button[disabled]"
      end

      def test_submit_button_with_data_attributes
        render_inline(Component.new(text: "Submit", type: "submit", data: {confirm: "Are you sure?"}))
        assert_selector "button[type='submit'][data-confirm='Are you sure?']", text: "Submit"
      end

      def test_submit_button_with_aria_label
        render_inline(Component.new(text: "Submit", type: "submit", aria: {label: "Submit form"}))
        assert_selector "button[type='submit'][aria-label='Submit form']", text: "Submit"
      end

      def test_primary_button_uses_scheme_shadow_token_class
        render_inline(Component.new(text: "Primary", style: :primary))

        html = page.native.to_html
        assert_includes html, "fp-button"
        assert_includes html, "fp-button-raised"
        assert_includes html, "data-fp-style=\"primary\""
        assert_includes html, "ease-[var(--easing-standard)]"
        assert_includes html, "duration-[var(--duration-fast)]"
        refute_includes html, "active:scale"
        refute_includes html, "bg-[var(--button-primary-background-color)]"
      end

      def test_secondary_button_does_not_include_scheme_shadow_class
        render_inline(Component.new(text: "Secondary", style: :secondary))

        html = page.native.to_html
        assert_includes html, "fp-button"
        assert_includes html, "fp-button-flat"
        assert_includes html, "data-fp-style=\"secondary\""
        refute_includes html, "fp-button-raised"
        refute_includes html, "active:scale"
      end

      def test_ghost_button_uses_flat_press_class
        render_inline(Component.new(text: "Ghost", style: :ghost))

        html = page.native.to_html
        assert_includes html, "fp-button"
        assert_includes html, "fp-button-flat"
        assert_includes html, "data-fp-style=\"ghost\""
        refute_includes html, "fp-button-raised"
        refute_includes html, "active:scale"
      end

      def test_registered_style_renders_data_attribute
        FlatPack::Button.register_style(:spec_partner, press: :raised)
        render_inline(Component.new(text: "Checkout", style: :spec_partner))

        assert_selector "button[data-fp-style='spec_partner']", text: "Checkout"
        assert_selector "button.fp-button-raised"
      ensure
        FlatPack::Button.unregister_style(:spec_partner)
      end

      def test_registered_flat_style_uses_flat_press
        FlatPack::Button.register_style(:spec_quiet, press: :flat)
        render_inline(Component.new(text: "Quiet", style: :spec_quiet))

        html = page.native.to_html
        assert_includes html, "data-fp-style=\"spec_quiet\""
        assert_includes html, "fp-button-flat"
        refute_includes html, "fp-button-raised"
      ensure
        FlatPack::Button.unregister_style(:spec_quiet)
      end

      def test_registered_style_does_not_recolor_built_in_primary
        FlatPack::Button.register_style(:spec_partner, press: :raised)
        render_inline(Component.new(text: "Keep primary", style: :primary))

        assert_selector "button[data-fp-style='primary']", text: "Keep primary"
        refute_selector "button[data-fp-style='spec_partner']"
      ensure
        FlatPack::Button.unregister_style(:spec_partner)
      end

      def test_invalid_style_message_includes_registered_name
        FlatPack::Button.register_style(:spec_partner, press: :raised)
        error = assert_raises(ArgumentError) do
          Component.new(text: "Invalid", style: :not_a_style)
        end

        assert_match(/spec_partner/, error.message)
        assert_match(/primary/, error.message)
      ensure
        FlatPack::Button.unregister_style(:spec_partner)
      end

      def test_default_align_is_center_and_lines_clamp_to_one
        render_inline(Component.new(text: "Save"))

        html = page.native.to_html
        assert_selector "button.items-center.justify-center"
        assert_selector "button > span.truncate.min-w-0.max-w-full.text-center", text: "Save"
        refute_includes html, "line-clamp-2"
        refute_includes html, "flex-1"
        refute_includes html, "fp-button-current"
      end

      def test_align_start_lets_the_label_fill_remaining_space
        render_inline(Component.new(text: "Logos", align: :start))

        assert_selector "button.justify-start.items-center"
        assert_selector "button > span.flex-1.min-w-0.text-start.truncate", text: "Logos"
      end

      def test_lines_two_clamps_and_top_aligns
        render_inline(Component.new(text: "Logos and lockups", lines: 2, align: :start))

        assert_selector "button.items-start"
        assert_selector "button > span.line-clamp-2", text: "Logos and lockups"
      end

      def test_title_sets_the_full_text_tooltip
        render_inline(Component.new(
          text: "Logos and lockups",
          title: "Logos and lockups for print and screen",
          lines: 2
        ))

        assert_selector "button[title='Logos and lockups for print and screen']"
      end

      def test_trailing_slot_is_fixed_width_and_top_aligned_when_the_label_wraps
        render_inline(Component.new(text: "Logos and lockups", icon: "photo", align: :start, lines: 2)) do |button|
          button.with_trailing { count_badge }
        end

        button = page.find("button")
        children = button.native.element_children
        assert_equal %w[svg span span], children.map(&:name)
        assert_equal "Logos and lockups", children[1].text
        assert_includes children[1]["class"], "flex-1"
        assert_includes children[1]["class"], "min-w-0"
        assert_includes children[2]["class"], "shrink-0"
        assert_includes children[2]["class"], "self-start"
        assert_equal "12", children[2].text
        assert_selector "button svg[aria-hidden='true']"
        assert_includes page.native.to_html, "focus-visible:ring-2"
      end

      def test_leading_icon_stays_hidden_from_assistive_tech
        render_inline(Component.new(text: "Search", icon: "magnifying-glass"))

        assert_selector "button svg[aria-hidden='true'][data-flat-pack--icon-name-value='magnifying-glass']"
        refute_selector "button svg[aria-label]"
      end

      def test_icon_variant_defaults_to_the_configured_heroicon_weight
        FlatPack.configuration = nil
        render_inline(Component.new(text: "Search", icon: "magnifying-glass"))

        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-variant-value='outline']"
        refute_selector "button svg[data-icon-style]"
      ensure
        FlatPack.configuration = nil
      end

      def test_icon_variant_and_icon_style_reach_the_leading_icon
        render_inline(Component.new(
          text: "Published",
          icon: "check-circle",
          icon_variant: :solid,
          icon_style: :success
        ))

        assert_selector "button[data-fp-style='default'] svg.fp-button-icon[data-flat-pack--icon-variant-value='solid'][data-flat-pack--icon-name-value='check-circle'][data-icon-style='success']"
        assert_includes page.native.to_html, FlatPack::Button::IconOptions::STYLES.fetch(:success)
      end

      def test_icon_variant_accepts_a_string_and_icon_style_can_be_omitted
        render_inline(Component.new(text: "Add", icon: "plus", icon_variant: "mini"))

        assert_selector "button svg[data-flat-pack--icon-variant-value='mini'][viewbox='0 0 20 20']"
        refute_selector "button svg[data-icon-style]"
      end

      def test_matching_icon_style_uses_the_button_text_colour
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

        assert_includes css, '.fp-button[data-fp-style="success"] .fp-button-icon[data-icon-style="success"]'
        assert_includes css, "color: var(--fp-button-text);"
        refute_includes css, "justify-content: center"
        refute_match(/\.fp-button-icon[^{]*\{[^}]*opacity:\s*1/, css)
      end

      def test_disabled_button_keeps_the_opacity_that_mutes_the_icon
        render_inline(Component.new(
          text: "Published",
          icon: "check-circle",
          icon_variant: :solid,
          icon_style: :success,
          disabled: true
        ))

        assert_selector "button[disabled].fp-button svg.fp-button-icon[data-icon-style='success']"
        assert_includes page.native.to_html, "disabled:opacity-[var(--button-disabled-opacity)]"
        refute_includes page.native.to_html, "opacity-100"
      end

      def test_heroicon_options_ignore_a_render_icon_override
        component = Component.new(
          text: "Published",
          icon: "check-circle",
          icon_variant: :solid,
          icon_style: :success
        )
        component.define_singleton_method(:render_icon) { raise "host render_icon should not paint a Heroicon" }

        render_inline(component)

        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-variant-value='solid'][data-icon-style='success']"
      end

      def test_inline_svg_icon_renders_as_an_svg_element
        render_inline(Component.new(text: "Google", icon: inline_mark_svg))

        html = page.native.to_html
        assert_selector "button > span[aria-hidden='true'] > svg[data-logo='mark']"
        refute_selector "button svg[data-flat-pack--icon-name-value]"
        refute_includes html, "&lt;svg"
        refute_selector "button", text: /<svg/
        assert_includes html, "w-5"
        assert_includes html, "h-5"
        assert_includes html, "[&amp;_svg]:h-full"
      end

      def test_inline_svg_icon_ignores_leading_whitespace
        render_inline(Component.new(text: "Google", icon: "  \n#{inline_mark_svg}"))

        assert_selector "button > span[aria-hidden='true'] > svg[data-logo='mark']"
      end

      def test_heroicon_name_still_renders_a_kit_icon
        render_inline(Component.new(text: "Search", icon: "magnifying-glass"))

        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-name-value='magnifying-glass']"
        refute_selector "button > svg[data-logo]"
      end

      def test_short_icon_alias_still_maps_to_a_heroicon
        render_inline(Component.new(text: "Search", icon: "search"))

        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-name-value='magnifying-glass']"
      end

      def test_inline_svg_icon_uses_the_heroicon_box_at_each_size
        render_inline(Component.new(text: "Google", icon: inline_mark_svg, size: :sm))
        html = page.native.to_html
        assert_includes html, "w-4"
        assert_includes html, "h-4"

        render_inline(Component.new(icon: inline_mark_svg, icon_only: true, size: :xs, text: "Google"))
        html = page.native.to_html
        assert_includes html, "w-4"
        assert_includes html, "h-4"
        assert_includes html, "fp-hit-slop"
      end

      def test_icon_only_inline_svg_keeps_hit_target_and_accessible_name
        render_inline(Component.new(icon: inline_mark_svg, icon_only: true, text: "Google"))

        assert_selector "button[aria-label='Google'] > span[aria-hidden='true'] > svg[data-logo='mark']"
        refute_selector "button span", text: "Google"
        assert_includes page.native.to_html, "fp-hit-target"
        refute_selector "button svg[data-flat-pack--icon-name-value]"
      end

      def test_inline_svg_link_button_keeps_the_icon_ahead_of_the_label
        render_inline(Component.new(text: "Google", href: "/auth/google", icon: inline_mark_svg))

        assert_selector "a[href='/auth/google'] > span[aria-hidden='true'] > svg[data-logo='mark']"
        assert_selector "a[href='/auth/google'] > span", text: "Google"
      end

      def test_inline_svg_still_reaches_a_render_icon_override
        component = Component.new(text: "Google", icon: '<svg data-logo="mark"></svg>', icon_style: :success)
        component.define_singleton_method(:render_icon) { "<span id=\"host-logo\">logo</span>".html_safe }

        render_inline(component)

        assert_selector "#host-logo", text: "logo"
        refute_selector "svg[data-flat-pack--icon-name-value]"
      end

      def test_invalid_icon_variant_and_icon_style
        variant_error = assert_raises(ArgumentError) { Component.new(text: "Save", icon_variant: :filled) }
        assert_match(/icon_variant/, variant_error.message)

        style_error = assert_raises(ArgumentError) { Component.new(text: "Save", icon_style: :info) }
        assert_match(/icon_style/, style_error.message)
      end

      def test_current_link_sets_aria_current_and_keeps_the_focus_ring
        render_inline(Component.new(text: "Logos", href: "/logos", current: true))

        html = page.native.to_html
        assert_selector "a[href='/logos'][aria-current='page'].fp-button-current", text: "Logos"
        assert_includes html, "focus-visible:ring-2"
        assert_includes html, "focus-visible:ring-inset"
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        assert_includes css, ".fp-button.fp-button-current,"
        assert_includes css, ".fp-button.fp-button-current:hover:not(:disabled)"
        assert_includes css, "background-color: var(--surface-active-background-color);"
        assert_includes css, "color: var(--surface-active-text-color);"
        assert_includes css, "border-color: var(--surface-active-border-color);"
        refute_includes css, "justify-content: center"
      end

      def test_current_button_uses_the_active_look_without_aria_current
        render_inline(Component.new(text: "Logos", current: true))

        assert_selector "button.fp-button-current", text: "Logos"
        refute_selector "[aria-current]"
      end

      def test_loading_hides_the_trailing_slot
        render_inline(Component.new(text: "Save", loading: true)) do |button|
          button.with_trailing { count_badge }
        end

        assert_selector "button", text: "Loading"
        refute_selector "button", text: "12"
      end

      def test_icon_only_rejects_a_trailing_slot
        component = Component.new(icon: "search", icon_only: true, text: "Search")
        component.with_trailing { "12" }

        error = assert_raises(ArgumentError) { render_inline(component) }
        assert_match(/icon-only/, error.message)
      end

      def test_round_defaults_to_the_theme_radius
        render_inline(Component.new(text: "Save"))

        html = page.native.to_html
        assert_includes html, "rounded-[var(--button-border-radius)]"
        refute_includes html, "rounded-[var(--button-round-border-radius)]"
        refute_includes html, "button-round-size"
      end

      def test_round_text_button_uses_the_round_radius_and_keeps_label_padding
        render_inline(Component.new(text: "Notify", round: true, size: :lg, style: :danger))

        html = page.native.to_html
        assert_includes html, "rounded-[var(--button-round-border-radius)]"
        refute_includes html, "rounded-[var(--button-border-radius)]"
        refute_includes html, "button-round-size"
        assert_includes html, "px-[var(--button-padding-x-lg)]"
        assert_selector "button", text: "Notify"
      end

      def test_round_icon_only_is_square_at_every_size
        %i[sm md lg].each do |size|
          render_inline(Component.new(icon: "bell", icon_only: true, round: true, size: size, aria: {label: "Notifications"}))

          html = page.native.to_html
          assert_includes html, "rounded-[var(--button-round-border-radius)]"
          assert_includes html, "h-[var(--button-round-size-#{size})]"
          assert_includes html, "w-[var(--button-round-size-#{size})]"
          assert_includes html, "p-[var(--button-icon-only-padding-#{size})]"
          assert_includes html, "fp-hit-target"
          assert_includes html, "shrink-0"
          refute_includes html, "rounded-[var(--button-border-radius)]"
        end
      end

      def test_icon_only_without_round_keeps_theme_radius_and_padding
        render_inline(Component.new(icon: "bell", icon_only: true, aria: {label: "Notifications"}))

        html = page.native.to_html
        assert_includes html, "p-[var(--button-icon-only-padding-md)]"
        assert_includes html, "rounded-[var(--button-border-radius)]"
        refute_includes html, "button-round-size"
        refute_includes html, "rounded-[var(--button-round-border-radius)]"
      end

      def test_round_host_radius_class_still_wins
        render_inline(Component.new(text: "Notify", round: true, class: "rounded-xl"))

        assert_selector "button.rounded-xl"
        html = page.native.to_html
        refute_includes html, "rounded-[var(--button-round-border-radius)]"
        refute_includes html, "rounded-[var(--button-border-radius)]"
      end

      def test_round_link_loading_and_current_keep_the_round_radius
        FlatPack::Button::StyleRegistry::BUILT_IN.each_key do |style|
          render_inline(Component.new(text: "Go", round: true, style: style, href: "/alerts", current: true, loading: true))

          assert_selector "a[href='/alerts'][aria-current='page'][aria-busy='true']"
          html = page.native.to_html
          assert_includes html, "fp-button-current"
          assert_includes html, "fp-spinner"
          assert_includes html, "rounded-[var(--button-round-border-radius)]"
          assert_includes html, "focus-visible:ring-2"
          assert_includes html, "focus-visible:ring-inset"
          assert_includes html, "focus-visible:ring-offset-2"
        end
      end

      def test_round_icon_only_loading_button_stays_square
        render_inline(Component.new(icon: "bell", icon_only: true, round: true, loading: true, size: :sm, aria: {label: "Notifications"}))

        assert_selector "button[disabled][aria-busy='true'][aria-label='Notifications']"
        html = page.native.to_html
        assert_includes html, "fp-spinner"
        assert_includes html, "h-[var(--button-round-size-sm)]"
        assert_includes html, "w-[var(--button-round-size-sm)]"
        refute_selector "button", text: "Loading"
      end

      def test_xs_icon_only_uses_slop_and_a_one_rem_icon
        render_inline(Component.new(icon: "heart", icon_only: true, round: true, size: :xs, aria: {label: "Save"}))

        html = page.native.to_html
        assert_includes html, "p-[var(--button-icon-only-padding-xs)]"
        assert_includes html, "h-[var(--button-round-size-xs)]"
        assert_includes html, "w-[var(--button-round-size-xs)]"
        assert_includes html, "fp-hit-slop"
        assert_includes html, "w-4 h-4"
        refute_includes html, "fp-hit-target"
        assert_selector "button[aria-label='Save']"
        assert_hit_slop_does_not_cover_the_button_fill
      end

      def test_xs_without_icon_only_raises
        error = assert_raises(ArgumentError) do
          Component.new(text: "Save", size: :xs)
        end

        assert_equal FlatPack::Button::Component::XS_REQUIRES_ICON_ONLY, error.message
      end

      def test_labeled_sizes_stay_on_the_shared_table
        assert_equal %i[sm md lg], FlatPack::Button::Component::SIZES.keys
        refute_includes FlatPack::Button::Component::SIZES.keys, :xs

        %i[sm md lg].each do |size|
          render_inline(Component.new(text: "Save", size: size))
          html = page.native.to_html
          assert_includes html, FlatPack::Button::Component::SIZES.fetch(size)
          refute_includes html, "fp-hit-slop"
          refute_includes html, "button-icon-only-padding-xs"
          refute_includes html, "button-round-size-xs"
        end
      end

      def test_existing_icon_only_sizes_keep_the_hit_target
        %i[sm md lg].each do |size|
          render_inline(Component.new(icon: "bell", icon_only: true, size: size, aria: {label: "Notifications"}))
          html = page.native.to_html
          assert_includes html, "fp-hit-target"
          refute_includes html, "fp-hit-slop"
        end
      end

      def test_invalid_round_raises
        [nil, :round, "true", 1].each do |round|
          error = assert_raises(ArgumentError) { Component.new(text: "Save", round: round) }
          assert_match(/round/, error.message)
        end
      end

      def test_invalid_align_lines_current_and_title
        error = assert_raises(ArgumentError) { Component.new(text: "Save", align: :end) }
        assert_match(/align/, error.message)

        error = assert_raises(ArgumentError) { Component.new(text: "Save", lines: 3) }
        assert_match(/lines/, error.message)

        error = assert_raises(ArgumentError) { Component.new(text: "Save", current: "page") }
        assert_match(/current/, error.message)

        error = assert_raises(ArgumentError) { Component.new(text: "Save", title: 12) }
        assert_match(/title/, error.message)
      end

      private

      def assert_hit_slop_does_not_cover_the_button_fill
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        layer_open = css.index("@layer components {")
        slop = css.index(".fp-hit-slop {")
        after_layer = css.index(".fp-read-more {")
        button = css.index(".fp-button {")

        assert layer_open < slop
        assert slop < after_layer
        assert after_layer < button
        assert_includes css, ".fp-hit-slop::after"
        assert_includes css, "width: var(--hit-target-min);"
        assert_includes css, "height: var(--hit-target-min);"
        assert_includes css, ".fp-button {\n  background-color: var(--fp-button-background);"
      end

      def count_badge
        vc_test_controller.view_context.render(
          FlatPack::Badge::Component.new(text: "12", size: :sm)
        )
      end

      def inline_mark_svg
        %(<svg data-logo="mark" viewBox="0 0 24 24" fill="currentColor"><circle cx="12" cy="12" r="8"></circle></svg>)
      end
    end
  end
end
