# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class DropdownComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_dropdown_with_trigger_button
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button", text: "Actions"
        assert_selector "div[role='menu']"
      end

      def test_renders_dropdown_with_chevron_icon
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
      end

      def test_chevron_name_sits_after_the_label
        render_inline(Dropdown::Component.new(text: "More", chevron: "archive"))

        trigger = page.find("button")
        assert_equal ["span", "span"], trigger.native.element_children.map(&:name)
        chevron = trigger.find("span:last-child svg")
        assert_equal "archive", chevron["data-flat-pack--icon-name-value"]
        assert_nil chevron["data-flat-pack--button-dropdown-target"]

        error = assert_raises(ArgumentError) { Dropdown::Component.new(text: "More", chevron: true) }
        assert_equal "chevron must be a string", error.message
      end

      def test_hides_chevron_when_show_chevron_is_false
        render_inline(Dropdown::Component.new(text: "Actions", show_chevron: false))

        assert_no_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
      end

      def test_renders_menu_with_hidden_class
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "div[role='menu'].hidden"
        assert_selector "div[role='menu'].opacity-0"
        assert_selector "div[role='menu'].scale-95"
        assert_includes page.native.to_html, "transition-[opacity,transform]"
        assert_includes page.native.to_html, "ease-[var(--easing-enter)]"
      end

      # Style variants
      def test_renders_primary_style
        render_inline(Dropdown::Component.new(text: "Actions", style: :primary))

        assert_selector "button"
        assert_includes page.native.to_html, "data-fp-style=\"primary\""
        assert_includes page.native.to_html, "fp-button"
      end

      def test_renders_secondary_style
        render_inline(Dropdown::Component.new(text: "Actions", style: :secondary))

        assert_selector "button"
        assert_includes page.native.to_html, "data-fp-style=\"secondary\""
      end

      def test_renders_ghost_style
        render_inline(Dropdown::Component.new(text: "Actions", style: :ghost))

        assert_selector "button"
        assert_includes page.native.to_html, "data-fp-style=\"ghost\""
      end

      def test_renders_success_style
        render_inline(Dropdown::Component.new(text: "Actions", style: :success))

        assert_selector "button"
        assert_includes page.native.to_html, "data-fp-style=\"success\""
      end

      def test_renders_warning_style
        render_inline(Dropdown::Component.new(text: "Actions", style: :warning))

        assert_selector "button"
        assert_includes page.native.to_html, "data-fp-style=\"warning\""
      end

      def test_renders_registered_style
        FlatPack::Button.register_style(:spec_partner, press: :raised)
        render_inline(Dropdown::Component.new(text: "Actions", style: :spec_partner))

        assert_includes page.native.to_html, "data-fp-style=\"spec_partner\""
        assert_includes page.native.to_html, "fp-button-raised"
      ensure
        FlatPack::Button.unregister_style(:spec_partner)
      end

      def test_raises_error_for_invalid_style
        error = assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "Actions", style: :not_a_style)
        end

        assert_match(/Invalid style/, error.message)
      end

      # Size variants
      def test_renders_small_size
        render_inline(Dropdown::Component.new(text: "Actions", size: :sm))

        assert_selector "button"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-sm)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-sm)]"
        assert_includes page.native.to_html, "text-xs"
      end

      def test_renders_medium_size
        render_inline(Dropdown::Component.new(text: "Actions", size: :md))

        assert_selector "button"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-md)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-md)]"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_large_size
        render_inline(Dropdown::Component.new(text: "Actions", size: :lg))

        assert_selector "button"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-lg)]"
        assert_includes page.native.to_html, "py-[var(--button-padding-y-lg)]"
        assert_includes page.native.to_html, "text-base"
      end

      # Position options
      def test_renders_bottom_right_position
        render_inline(Dropdown::Component.new(text: "Actions", placement: :bottom_right))

        assert_selector "div[data-controller='flat-pack--button-dropdown'][data-flat-pack--button-dropdown-placement-value='bottom_right']"
      end

      def test_renders_bottom_left_position
        render_inline(Dropdown::Component.new(text: "Actions", placement: :bottom_left))

        assert_selector "div[data-controller='flat-pack--button-dropdown'][data-flat-pack--button-dropdown-placement-value='bottom_left']"
      end

      def test_renders_top_right_position
        render_inline(Dropdown::Component.new(text: "Actions", placement: :top_right))

        assert_selector "div[data-controller='flat-pack--button-dropdown'][data-flat-pack--button-dropdown-placement-value='top_right']"
      end

      def test_renders_top_left_position
        render_inline(Dropdown::Component.new(text: "Actions", placement: :top_left))

        assert_selector "div[data-controller='flat-pack--button-dropdown'][data-flat-pack--button-dropdown-placement-value='top_left']"
      end

      def test_raises_error_for_invalid_position
        assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "Actions", placement: :invalid)
        end
      end

      # Icon support
      def test_renders_button_with_icon
        render_inline(Dropdown::Component.new(text: "Actions", icon: "settings"))

        assert_selector "button", text: "Actions"
        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-name-value='cog-6-tooth']"
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-down']:not(.fp-button-icon)"
      end

      def test_trigger_picks_up_an_inline_svg_icon
        svg = '<svg data-logo="mark" class="block h-5 w-5 shrink-0" viewBox="0 0 24 24"></svg>'
        render_inline(Dropdown::Component.new(text: "Google", icon: svg))

        assert_selector "button > span[aria-hidden='true'] > svg[data-logo='mark']"
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-down']"
        refute_selector "button svg[data-flat-pack--icon-name-value][data-logo]"
      end

      def test_leading_icon_takes_variant_and_style_and_the_chevron_does_not
        render_inline(Dropdown::Component.new(
          text: "Publish",
          icon: "check-circle",
          icon_variant: :solid,
          icon_style: :success
        ))

        assert_selector "button svg.fp-button-icon[data-flat-pack--icon-variant-value='solid'][data-icon-style='success'][data-flat-pack--icon-name-value='check-circle']"
        assert_includes page.native.to_html, FlatPack::Button::IconOptions::STYLES.fetch(:success)
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-down'][data-flat-pack--icon-variant-value='outline']"
        refute_selector "button svg[data-flat-pack--icon-name-value='chevron-down'][data-icon-style]"
        refute_selector "button svg[data-flat-pack--icon-name-value='chevron-down'].fp-button-icon"
      end

      def test_invalid_dropdown_icon_variant_and_icon_style
        assert_raises(ArgumentError) { Dropdown::Component.new(text: "Actions", icon_variant: :filled) }
        assert_raises(ArgumentError) { Dropdown::Component.new(text: "Actions", icon_style: :info) }
      end

      def test_applies_trigger_attributes_to_button
        render_inline(Dropdown::Component.new(
          text: "",
          icon: "dots",
          show_chevron: false,
          trigger_attributes: {
            title: "Conversation actions",
            aria: {label: "Conversation actions"}
          }
        ))

        assert_selector "button[title='Conversation actions'][aria-label='Conversation actions']"
      end

      def test_trigger_attributes_do_not_replace_button_options
        render_inline(Dropdown::Component.new(
          text: "Actions",
          style: :primary,
          size: :md,
          icon: "cog-6-tooth",
          trigger_attributes: {
            style: :not_a_style,
            size: :huge,
            text: "Nope",
            icon: "nope",
            type: "submit",
            title: "Conversation actions"
          }
        ))

        assert_selector "button.fp-button[data-fp-style='primary'][type='submit'][title='Conversation actions']", text: "Actions"
        assert_selector "button svg[data-flat-pack--icon-name-value='cog-6-tooth']"
        refute_selector "button", text: "Nope"
      end

      def test_trigger_attributes_drop_style_string_href_method_and_target
        render_inline(Dropdown::Component.new(
          text: "Actions",
          trigger_attributes: {
            style: "color: red",
            href: "/secret",
            method: :delete,
            target: "_blank",
            title: "Kept"
          }
        ))

        button = page.find("button.fp-button-dropdown__trigger")
        assert_equal "Kept", button["title"]
        assert_nil button["style"]
        assert_nil button["href"]
        assert_nil button["target"]
        refute_includes button.native.attribute("method")&.value.to_s, "delete"
        html = button.native.to_html
        refute_includes html, "color: red"
        refute_includes html, "/secret"
        refute_includes html, "_blank"
      end

      # Disabled state
      def test_renders_disabled_button
        render_inline(Dropdown::Component.new(text: "Actions", disabled: true))

        assert_selector "button[disabled]"
      end

      # Items rendering
      def test_renders_dropdown_menu_items
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Edit", href: "/edit")
          dropdown.menu_item(text: "Delete", href: "/delete")
        end

        assert_selector "a[href='/edit']", text: "Edit"
        assert_selector "a[href='/delete']", text: "Delete"
        assert_includes page.native.to_html, "rounded-[var(--dropdown-item-radius)]"
      end

      def test_renders_dropdown_menu_items_and_divider
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Edit", href: "/edit")
          dropdown.menu_divider
          dropdown.menu_item(text: "Delete", href: "/delete")
        end

        assert_selector "a[href='/edit']", text: "Edit"
        assert_selector "div[role='separator']"
        assert_selector "a[href='/delete']", text: "Delete"
      end

      def test_renders_item_with_icon
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Edit", icon: "edit", href: "/edit")
        end

        assert_selector "a[href='/edit']", text: "Edit"
        assert_selector "a[href='/edit'] svg.fp-button-icon[data-flat-pack--icon-name-value='edit']"
      end

      def test_menu_item_icon_takes_variant_and_style
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(
            text: "Unpublish",
            icon: "x-circle",
            icon_variant: :mini,
            icon_style: :danger,
            href: "/unpublish"
          )
        end

        assert_selector "a[href='/unpublish'] svg.fp-button-icon[data-flat-pack--icon-variant-value='mini'][data-icon-style='danger'][data-flat-pack--icon-name-value='x-circle']"
        assert_includes page.native.to_html, FlatPack::Button::IconOptions::STYLES.fetch(:danger)
      end

      def test_invalid_menu_item_icon_style
        dropdown = Dropdown::Component.new(text: "Actions")

        assert_raises(ArgumentError) do
          dropdown.menu_item(text: "Edit", icon_style: :info)
        end
      end

      def test_renders_item_with_badge
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Messages", badge: "5", href: "/messages")
        end

        assert_selector "a[href='/messages']", text: "Messages"
        assert_selector "span", text: "5"
      end

      def test_renders_disabled_item
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Disabled", disabled: true)
        end

        assert_selector "button[disabled]", text: "Disabled"
      end

      def test_renders_destructive_item
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Delete", destructive: true, href: "/delete")
        end

        assert_selector "a[href='/delete']", text: "Delete"
        assert_includes page.native.to_html, "text-danger-text-color"
      end

      # Accessibility attributes
      def test_renders_aria_haspopup_attribute
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button[aria-haspopup='true']"
      end

      def test_renders_aria_expanded_false
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button[aria-expanded='false']"
      end

      def test_renders_menu_role
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "div[role='menu']"
      end

      def test_renders_menuitem_role_on_items
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Edit", href: "/edit")
        end

        assert_selector "a[role='menuitem']"
      end

      def test_renders_separator_role_on_divider
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_divider
        end

        assert_selector "div[role='separator']"
      end

      # Stimulus integration
      def test_renders_stimulus_controller
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "div[data-controller='flat-pack--button-dropdown']"
        assert_selector "div[data-flat-pack--button-dropdown-placement-value='bottom_right']"
      end

      def test_renders_stimulus_target_on_trigger
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button[data-flat-pack--button-dropdown-target='trigger']"
      end

      def test_renders_stimulus_target_on_menu
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "div[data-flat-pack--button-dropdown-target='menu']"
        assert_selector "div[role='menu'].fixed"
      end

      def test_renders_stimulus_action_on_trigger
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_selector "button[data-action='click->flat-pack--button-dropdown#toggle']"
      end

      # Max height
      def test_renders_custom_max_height
        render_inline(Dropdown::Component.new(text: "Actions", max_height: "200px"))

        menu = page.find("div[role='menu']")
        assert_includes menu["style"], "--dropdown-max-height: 200px"
        refute_match(/(^|;)\s*max-height\s*:/, menu["style"])
        assert_includes menu["class"], "fp-button-dropdown__menu"
      end

      def test_default_max_height_is_384px
        render_inline(Dropdown::Component.new(text: "Actions"))

        assert_includes page.find("div[role='menu']")["style"], "--dropdown-max-height: 384px"
      end

      def test_menu_renders_one_max_height_style_attribute
        render_inline(Dropdown::Component.new(text: "Actions", max_height: "200px", menu_attributes: {style: "color: red"}))

        menu = page.native.at_css("div[role='menu']")
        opening = menu.to_html[/\A<div[^>]*>/]

        assert_equal 1, opening.scan(/\sstyle="/).size
        assert_match(/--dropdown-max-height:\s*200px/, opening)
        assert_match(/color:\s*red/, opening)
        refute_match(/(^|;)\s*max-height\s*:/, menu["style"])
      end

      def test_menu_max_height_comes_from_the_css_variable
        css = File.read(FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css"))

        assert_includes css, ".fp-button-dropdown__menu"
        assert_includes css, "max-height: var(--dropdown-max-height, 384px);"
      end

      # Custom attributes
      def test_accepts_custom_classes
        render_inline(Dropdown::Component.new(text: "Actions", class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Dropdown::Component.new(text: "Actions", data: {test: "value"}))

        assert_selector "div[data-test='value']"
      end

      def test_accepts_id_attribute
        render_inline(Dropdown::Component.new(text: "Actions", id: "my-dropdown"))

        assert_selector "div#my-dropdown"
      end

      # Item validation
      def test_item_sanitizes_unsafe_url
        assert_raises(ArgumentError) do
          render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
            dropdown.menu_item(text: "Evil", href: "javascript:alert('xss')")
          end
        end
      end

      def test_item_allows_safe_url
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Safe", href: "https://example.com")
        end

        assert_selector "a[href='https://example.com']", text: "Safe"
      end

      def test_item_allows_relative_url
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Safe", href: "/path/to/page")
        end

        assert_selector "a[href='/path/to/page']", text: "Safe"
      end

      def test_default_trigger_html_stays_the_labeled_button
        render_inline(Dropdown::Component.new(text: "Actions"))
        default_html = page.native.to_html

        render_inline(Dropdown::Component.new(text: "Actions", icon_only: false, round: false))

        assert_equal default_html, page.native.to_html
        trigger = page.find("button")
        assert_includes trigger["class"], "fp-button"
        assert_includes trigger["class"], "fp-button-dropdown__trigger"
        assert_equal "default", trigger["data-fp-style"]
        assert_equal "click->flat-pack--button-dropdown#toggle", trigger["data-action"]
        assert_equal "trigger", trigger["data-flat-pack--button-dropdown-target"]
        assert_equal "true", trigger["aria-haspopup"]
        assert_equal "false", trigger["aria-expanded"]
        assert_selector "button span", text: "Actions"
        assert_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
        refute_includes default_html, "fp-hit-target"
        refute_includes default_html, "button-round-size"
        refute_includes default_html, "button-icon-only-padding"
        refute_includes default_html, "aria-label"
      end

      def test_icon_only_uses_button_padding_hit_target_and_hides_the_label
        %i[sm md lg].each do |size|
          render_inline(Dropdown::Component.new(text: "Add to list", icon: "heart", icon_only: true, size: size))

          html = page.native.to_html
          assert_selector "button[aria-label='Add to list'][aria-haspopup='true'][aria-expanded='false']"
          refute_selector "button span", text: "Add to list"
          refute_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
          assert_includes html, FlatPack::Button::Component::ICON_ONLY_SIZES.fetch(size)
          assert_includes html, "fp-hit-target"
          assert_includes html, "rounded-[var(--button-border-radius)]"
          refute_includes html, "button-round-size"
          refute_includes html, FlatPack::Button::Component::SIZES.fetch(size)
        end
      end

      def test_xs_icon_only_trigger_uses_button_slop
        render_inline(Dropdown::Component.new(
          text: "Share",
          icon: "share",
          icon_only: true,
          round: true,
          size: :xs
        ))

        html = page.native.to_html
        assert_selector "button[aria-label='Share']"
        assert_includes html, "p-[var(--button-icon-only-padding-xs)]"
        assert_includes html, "h-[var(--button-round-size-xs)]"
        assert_includes html, "fp-hit-slop"
        assert_includes html, "w-4 h-4"
        refute_includes html, "fp-hit-target"
        refute_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
      end

      def test_xs_without_icon_only_raises
        error = assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "Share", size: :xs)
        end

        assert_equal FlatPack::Button::Component::XS_REQUIRES_ICON_ONLY, error.message
      end

      def test_round_icon_only_uses_button_circle_sizes
        %i[sm md lg].each do |size|
          render_inline(Dropdown::Component.new(
            text: "Add to list",
            icon: "heart",
            icon_only: true,
            round: true,
            size: size
          ))

          html = page.native.to_html
          assert_includes html, FlatPack::Button::Component::ROUND_RADIUS_CLASS
          assert_includes html, FlatPack::Button::Component::ROUND_ICON_ONLY_SIZES.fetch(size)
          assert_includes html, FlatPack::Button::Component::ICON_ONLY_SIZES.fetch(size)
          assert_includes html, "fp-hit-target"
          refute_includes html, "rounded-[var(--button-border-radius)]"
          refute_selector "button span", text: "Add to list"
        end
      end

      def test_round_labeled_trigger_keeps_label_padding_and_chevron
        render_inline(Dropdown::Component.new(text: "Notify", round: true, size: :lg))

        html = page.native.to_html
        assert_includes html, FlatPack::Button::Component::ROUND_RADIUS_CLASS
        assert_includes html, FlatPack::Button::Component::SIZES.fetch(:lg)
        refute_includes html, "button-round-size"
        refute_includes html, "fp-hit-target"
        assert_selector "button span", text: "Notify"
        assert_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
      end

      def test_icon_only_text_becomes_aria_label_and_keeps_popup_state
        render_inline(Dropdown::Component.new(text: "Add to list", icon: "heart", icon_only: true))

        assert_selector "button[aria-label='Add to list'][aria-haspopup='true'][aria-expanded='false']"
        refute_selector "button span", text: "Add to list"
      end

      def test_icon_only_keeps_trigger_aria_label
        render_inline(Dropdown::Component.new(
          text: "Heart",
          icon: "heart",
          icon_only: true,
          trigger_attributes: {aria: {label: "Add to list"}}
        ))

        assert_selector "button[aria-label='Add to list'][aria-haspopup='true'][aria-expanded='false']"
        refute_selector "button[aria-label='Heart']"
        refute_selector "button span", text: "Heart"
      end

      def test_icon_only_without_accessible_name_raises
        error = assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "", icon: "heart", icon_only: true)
        end

        assert_match("Icon-only buttons need an accessible name", error.message)
      end

      def test_icon_only_without_icon_raises
        error = assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "Add to list", icon_only: true)
        end

        assert_match(/icon/, error.message)
      end

      def test_icon_only_hides_the_chevron_unless_the_caller_asks_for_it
        render_inline(Dropdown::Component.new(text: "Add to list", icon: "heart", icon_only: true))
        refute_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"

        render_inline(Dropdown::Component.new(
          text: "Add to list",
          icon: "heart",
          icon_only: true,
          show_chevron: false
        ))
        refute_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"

        error = assert_raises(ArgumentError) do
          Dropdown::Component.new(text: "Add to list", icon: "heart", icon_only: true, show_chevron: true)
        end
        assert_match(/chevron/, error.message)
      end

      def test_catalog_reports_nil_chevron_default
        FlatPack::ComponentCatalog.reset!
        parameters = FlatPack::ComponentCatalog.show("Button::Dropdown::Component").fetch(:parameters)
        chevron = parameters.find { |row| row.fetch(:name) == "show_chevron" }
        icon_only = parameters.find { |row| row.fetch(:name) == "icon_only" }
        round = parameters.find { |row| row.fetch(:name) == "round" }

        assert chevron.key?(:default)
        assert_nil chevron.fetch(:default)
        assert_equal false, icon_only.fetch(:default)
        assert_equal false, round.fetch(:default)
      end

      def test_invalid_round_raises
        [nil, :round, "true", 1].each do |round|
          error = assert_raises(ArgumentError) { Dropdown::Component.new(text: "Actions", round: round) }
          assert_match(/round/, error.message)
        end
      end

      def test_menu_class_appends_to_the_menu
        render_inline(Dropdown::Component.new(text: "Actions", menu_class: "min-w-[18rem]"))

        menu = page.find("div[role='menu']")
        assert_includes menu["class"], "min-w-[18rem]"
        assert_includes menu["class"], "fixed"
        assert_includes menu["class"], "z-50"
      end

      def test_menu_attributes_merge_onto_the_menu
        render_inline(Dropdown::Component.new(
          text: "Actions",
          menu_attributes: {
            id: "host-menu",
            class: "w-72",
            data: {controller: "lists--add-to-list"},
            aria: {label: "Lists"},
            role: "dialog"
          }
        ))

        assert_selector "div[role='menu']#host-menu[aria-label='Lists'][aria-hidden='true']"
        menu = page.find("div[role='menu']#host-menu")
        assert_includes menu["class"], "w-72"
        assert_includes menu["data-controller"], "lists--add-to-list"
        assert_equal "menu", menu["data-flat-pack--button-dropdown-target"]
        refute_selector "div[role='dialog']"
      end

      def test_trigger_label_slot_replaces_the_visible_label
        render_inline(Dropdown::Component.new(text: "Lists")) do |dropdown|
          dropdown.with_trigger_label { "Lists · 3" }
          dropdown.menu_item(text: "Favorites", href: "/favorites")
        end

        assert_selector "button.fp-button-dropdown__trigger", text: "Lists · 3"
        refute_selector "button.fp-button-dropdown__trigger", text: "Lists", exact_text: true
        assert_selector "button[aria-haspopup='true'][aria-expanded='false']"
        assert_selector "button svg[data-flat-pack--button-dropdown-target='chevron']"
      end

      def test_omitting_host_hooks_keeps_the_default_menu_and_trigger
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Edit", icon: "edit", href: "/edit")
        end
        default_html = page.native.to_html

        render_inline(Dropdown::Component.new(
          text: "Actions",
          menu_class: nil,
          menu_attributes: {}
        )) do |dropdown|
          dropdown.menu_item(text: "Edit", icon: "edit", href: "/edit", icon_position: :start, keep_open: false)
        end

        assert_equal default_html, page.native.to_html
        refute_includes default_html, "order-last"
        refute_includes default_html, "data-flat-pack-dropdown-keep-open"
        refute_includes default_html, "fp-button-dropdown__form"
        assert_selector "a[role='menuitem'][href='/edit']", text: "Edit"
      end

      def test_item_icon_position_end_puts_the_icon_last
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Favorites", icon: "heart", icon_position: :end, href: "/favorites")
        end

        assert_selector "a[href='/favorites'] svg.fp-button-icon.order-last[data-flat-pack--icon-name-value='heart']"
        assert_selector "a[role='menuitem'][href='/favorites']", text: "Favorites"
      end

      def test_invalid_icon_position_raises
        dropdown = Dropdown::Component.new(text: "Actions")

        error = assert_raises(ArgumentError) do
          dropdown.menu_item(text: "Edit", icon: "edit", icon_position: :middle)
        end
        assert_match(/icon_position/, error.message)
      end

      def test_keep_open_item_keeps_menuitem_role
        render_inline(Dropdown::Component.new(text: "Actions")) do |dropdown|
          dropdown.menu_item(text: "Pin", keep_open: true)
          dropdown.menu_item(text: "Edit", href: "/edit")
        end

        assert_selector "button[role='menuitem'][data-flat-pack-dropdown-keep-open='true']", text: "Pin"
        assert_selector "a[role='menuitem'][href='/edit']"
        refute_selector "a[data-flat-pack-dropdown-keep-open]"
      end

      def test_invalid_keep_open_raises
        dropdown = Dropdown::Component.new(text: "Actions")

        error = assert_raises(ArgumentError) do
          dropdown.menu_item(text: "Pin", keep_open: "yes")
        end
        assert_match(/keep_open/, error.message)
      end

      def test_menu_form_is_a_dialog_without_menu_roles
        render_inline(Dropdown::Component.new(text: "Add to list")) do |dropdown|
          dropdown.menu_item(text: "Favorites", href: "/favorites")
          dropdown.menu_form do
            "<form><input name='name' type='text'><button type='submit'>Add</button></form>".html_safe
          end
        end

        assert_selector "div[role='dialog'][aria-modal='false'][aria-label='Add to list'].fp-button-dropdown__menu"
        assert_selector "button[aria-haspopup='dialog']"
        assert_selector "div.fp-button-dropdown__form[data-flat-pack-dropdown-keep-open='true'] form input[name='name']"
        assert_selector "a[href='/favorites']", text: "Favorites"
        refute_selector "[role='menu']"
        refute_selector "[role='menuitem']"
        refute_selector "[role='none']"
        refute_selector "form[role]"
        refute_selector "input[role]"
      end

      def test_catalog_reports_new_dropdown_defaults
        FlatPack::ComponentCatalog.reset!
        parameters = FlatPack::ComponentCatalog.show("Button::Dropdown::Component").fetch(:parameters)
        slots = FlatPack::ComponentCatalog.show("Button::Dropdown::Component").fetch(:slots)
        menu_class = parameters.find { |row| row.fetch(:name) == "menu_class" }
        menu_attributes = parameters.find { |row| row.fetch(:name) == "menu_attributes" }

        assert menu_class.key?(:default)
        assert_nil menu_class.fetch(:default)
        refute menu_attributes.key?(:default)
        assert_includes slots.map { |row| row.fetch(:name) }, "trigger_label"
        assert_includes slots.map { |row| row.fetch(:name) }, "menu"

        item = FlatPack::ComponentCatalog.show("Button::DropdownItem::Component")
        item_parameters = item.fetch(:parameters)
        icon_position = item_parameters.find { |row| row.fetch(:name) == "icon_position" }
        keep_open = item_parameters.find { |row| row.fetch(:name) == "keep_open" }

        assert_equal "start", icon_position.fetch(:default)
        assert_equal false, keep_open.fetch(:default)
      end

      def test_icon_only_menu_stays_fixed_for_every_placement
        %i[bottom_right bottom_left top_right top_left].each do |placement|
          render_inline(Dropdown::Component.new(
            text: "Add to list",
            icon: "heart",
            icon_only: true,
            round: true,
            placement: placement
          ))

          assert_selector "div[role='menu'].fixed[data-flat-pack--button-dropdown-target='menu']"
          assert_selector "div[data-flat-pack--button-dropdown-placement-value='#{placement}']"
          assert_selector "button[data-flat-pack--button-dropdown-target='trigger'][aria-haspopup='true']"
        end
      end
    end
  end
end
