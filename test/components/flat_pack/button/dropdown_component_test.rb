# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Button
    class DropdownComponentTest < ViewComponent::TestCase
      # Basic rendering tests
      def test_renders_dropdown_with_trigger_button
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button", text: "Actions"
        assert_selector "div[role='menu']"
      end

      def test_renders_dropdown_with_chevron_icon
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button svg[data-button-dropdown-target='chevron']"
      end

      def test_renders_menu_with_hidden_class
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "div[role='menu'].hidden"
        assert_selector "div[role='menu'].opacity-0"
        assert_selector "div[role='menu'].scale-95"
      end

      # Style variants
      def test_renders_primary_style
        render_inline(DropdownComponent.new(text: "Actions", style: :primary))

        assert_selector "button"
        assert_includes page.native.to_html, "bg-[var(--color-primary)]"
      end

      def test_renders_secondary_style
        render_inline(DropdownComponent.new(text: "Actions", style: :secondary))

        assert_selector "button"
        assert_includes page.native.to_html, "bg-[var(--color-secondary)]"
      end

      def test_renders_ghost_style
        render_inline(DropdownComponent.new(text: "Actions", style: :ghost))

        assert_selector "button"
        assert_includes page.native.to_html, "bg-[var(--color-ghost)]"
      end

      def test_renders_success_style
        render_inline(DropdownComponent.new(text: "Actions", style: :success))

        assert_selector "button"
        assert_includes page.native.to_html, "bg-[var(--color-success)]"
      end

      def test_renders_warning_style
        render_inline(DropdownComponent.new(text: "Actions", style: :warning))

        assert_selector "button"
        assert_includes page.native.to_html, "bg-[var(--color-warning)]"
      end

      # Size variants
      def test_renders_small_size
        render_inline(DropdownComponent.new(text: "Actions", size: :sm))

        assert_selector "button"
        assert_includes page.native.to_html, "px-3"
        assert_includes page.native.to_html, "py-1.5"
        assert_includes page.native.to_html, "text-xs"
      end

      def test_renders_medium_size
        render_inline(DropdownComponent.new(text: "Actions", size: :md))

        assert_selector "button"
        assert_includes page.native.to_html, "px-4"
        assert_includes page.native.to_html, "py-2"
        assert_includes page.native.to_html, "text-sm"
      end

      def test_renders_large_size
        render_inline(DropdownComponent.new(text: "Actions", size: :lg))

        assert_selector "button"
        assert_includes page.native.to_html, "px-6"
        assert_includes page.native.to_html, "py-3"
        assert_includes page.native.to_html, "text-base"
      end

      # Position options
      def test_renders_bottom_right_position
        render_inline(DropdownComponent.new(text: "Actions", position: :bottom_right))

        assert_selector "div[role='menu'].top-full.right-0"
      end

      def test_renders_bottom_left_position
        render_inline(DropdownComponent.new(text: "Actions", position: :bottom_left))

        assert_selector "div[role='menu'].top-full.left-0"
      end

      def test_renders_top_right_position
        render_inline(DropdownComponent.new(text: "Actions", position: :top_right))

        assert_selector "div[role='menu'].bottom-full.right-0"
      end

      def test_renders_top_left_position
        render_inline(DropdownComponent.new(text: "Actions", position: :top_left))

        assert_selector "div[role='menu'].bottom-full.left-0"
      end

      def test_raises_error_for_invalid_position
        assert_raises(ArgumentError) do
          DropdownComponent.new(text: "Actions", position: :invalid)
        end
      end

      # Icon support
      def test_renders_button_with_icon
        render_inline(DropdownComponent.new(text: "Actions", icon: "settings"))

        assert_selector "button", text: "Actions"
      end

      # Disabled state
      def test_renders_disabled_button
        render_inline(DropdownComponent.new(text: "Actions", disabled: true))

        assert_selector "button[disabled]"
      end

      # Items rendering
      def test_renders_dropdown_with_items
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Edit", href: "/edit")
          dropdown.with_item(text: "Delete", href: "/delete")
        end

        assert_selector "a[href='/edit']", text: "Edit"
        assert_selector "a[href='/delete']", text: "Delete"
      end

      def test_renders_dropdown_with_items_and_divider
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Edit", href: "/edit")
          dropdown.with_divider
          dropdown.with_item(text: "Delete", href: "/delete")
        end

        assert_selector "a[href='/edit']", text: "Edit"
        assert_selector "div[role='separator']"
        assert_selector "a[href='/delete']", text: "Delete"
      end

      def test_renders_item_with_icon
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Edit", icon: "edit", href: "/edit")
        end

        assert_selector "a[href='/edit']", text: "Edit"
      end

      def test_renders_item_with_badge
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Messages", badge: "5", href: "/messages")
        end

        assert_selector "a[href='/messages']", text: "Messages"
        assert_selector "span", text: "5"
      end

      def test_renders_disabled_item
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Disabled", disabled: true)
        end

        assert_selector "button[disabled]", text: "Disabled"
      end

      def test_renders_destructive_item
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Delete", destructive: true, href: "/delete")
        end

        assert_selector "a[href='/delete']", text: "Delete"
        assert_includes page.native.to_html, "text-[var(--color-destructive)]"
      end

      # Accessibility attributes
      def test_renders_aria_haspopup_attribute
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button[aria-haspopup='true']"
      end

      def test_renders_aria_expanded_false
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button[aria-expanded='false']"
      end

      def test_renders_menu_role
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "div[role='menu']"
      end

      def test_renders_menuitem_role_on_items
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Edit", href: "/edit")
        end

        assert_selector "a[role='menuitem']"
      end

      def test_renders_separator_role_on_divider
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_divider
        end

        assert_selector "div[role='separator']"
      end

      # Stimulus integration
      def test_renders_stimulus_controller
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "div[data-controller='button-dropdown']"
      end

      def test_renders_stimulus_target_on_trigger
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button[data-button-dropdown-target='trigger']"
      end

      def test_renders_stimulus_target_on_menu
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "div[data-button-dropdown-target='menu']"
      end

      def test_renders_stimulus_action_on_trigger
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "button[data-action='click->button-dropdown#toggle']"
      end

      # Max height
      def test_renders_custom_max_height
        render_inline(DropdownComponent.new(text: "Actions", max_height: "200px"))

        assert_selector "div[role='menu'][style*='max-height: 200px']"
      end

      def test_default_max_height_is_384px
        render_inline(DropdownComponent.new(text: "Actions"))

        assert_selector "div[role='menu'][style*='max-height: 384px']"
      end

      # Custom attributes
      def test_accepts_custom_classes
        render_inline(DropdownComponent.new(text: "Actions", class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_accepts_data_attributes
        render_inline(DropdownComponent.new(text: "Actions", data: { test: "value" }))

        assert_selector "div[data-test='value']"
      end

      def test_accepts_id_attribute
        render_inline(DropdownComponent.new(text: "Actions", id: "my-dropdown"))

        assert_selector "div#my-dropdown"
      end

      # Item validation
      def test_item_sanitizes_unsafe_url
        assert_raises(ArgumentError) do
          render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
            dropdown.with_item(text: "Evil", href: "javascript:alert('xss')")
          end
        end
      end

      def test_item_allows_safe_url
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Safe", href: "https://example.com")
        end

        assert_selector "a[href='https://example.com']", text: "Safe"
      end

      def test_item_allows_relative_url
        render_inline(DropdownComponent.new(text: "Actions")) do |dropdown|
          dropdown.with_item(text: "Safe", href: "/path/to/page")
        end

        assert_selector "a[href='/path/to/page']", text: "Safe"
      end
    end
  end
end
