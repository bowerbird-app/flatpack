# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Header
      class ComponentTest < ViewComponent::TestCase
        def test_renders_default_header_structure
          render_inline(Component.new)

          assert_text "FP"
          assert_text "FlatPack"
          assert_text "v#{FlatPack::VERSION}"
          assert_no_text "Workspace"
          assert_selector "div.flex.items-center.gap-3"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerBrand']"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel']"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'].flex.items-center.h-8"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > span", count: 1
          assert_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          assert_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
          assert_selector "[data-flat-pack--sidebar-layout-target='desktopToggle'][data-action='click->flat-pack--sidebar-layout#toggleDesktop click->flat-pack--sidebar-layout#toggleMobile']"
        end

        def test_renders_custom_brand_values
          render_inline(Component.new(brand_abbr: "AC", title: "Acme", subtitle: "Dummy App"))

          assert_text "AC"
          assert_text "Acme"
          assert_no_text "Dummy App"
        end

        def test_hides_toggle_buttons_when_not_collapsible
          render_inline(Component.new(collapsible: false))

          assert_no_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
        end

        def test_hides_brand_badge_when_brand_abbr_is_blank
          render_inline(Component.new(brand_abbr: nil, title: "Menu", subtitle: nil, collapsible: false))

          assert_text "Menu"
          assert_no_text "FP"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='headerBrand'] > .w-8.h-8"
        end

        def test_hides_subtitle_when_blank
          render_inline(Component.new(subtitle: nil))

          assert_no_text "Workspace"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > div", count: 1
        end

        def test_does_not_render_subtitle_even_when_provided
          render_inline(Component.new(subtitle: "Workspace"))

          assert_no_text "Workspace"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > div", count: 1
        end

        def test_hides_version_badge_when_show_version_false
          render_inline(Component.new(show_version: false))

          assert_text "FlatPack"
          assert_no_text "v#{FlatPack::VERSION}"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > span"
        end

        def test_shows_version_badge_when_show_version_true
          render_inline(Component.new(show_version: true))

          assert_text "v#{FlatPack::VERSION}"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > span", count: 1
        end

        def test_renders_square_mark_in_badge_slot_instead_of_abbr
          render_inline(Component.new(
            logo: "https://example.com/mark.png",
            brand_abbr: "AC",
            title: "Acme"
          ))

          assert_selector "img[src='https://example.com/mark.png'][alt='']"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerBrand'] .h-8"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerBrand'] .w-8"
          assert_selector "[data-flat-pack--sidebar-layout-target='headerBrand'] [aria-hidden='true']"
          assert_text "Acme"
          assert_text "v#{FlatPack::VERSION}"
          assert_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          assert_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
          assert_no_text "AC"
          refute_selector "div[data-controller='flat-pack--tooltip']"
        end

        def test_accepts_a_relative_logo_path
          render_inline(Component.new(
            logo: "/sidebar_brand_mark.svg",
            brand_abbr: "AC",
            title: "Acme"
          ))

          assert_selector "img[src='/sidebar_brand_mark.svg']"
          assert_no_text "AC"
        end

        def test_keeps_brand_abbr_when_logo_is_blank
          render_inline(Component.new(logo: "", brand_abbr: "AC", title: "Acme"))

          assert_text "AC"
          assert_text "Acme"
          refute_selector "img"
        end

        def test_keeps_brand_abbr_when_logo_is_nil
          render_inline(Component.new(logo: nil, brand_abbr: "AC", title: "Acme"))

          assert_text "AC"
          refute_selector "img"
        end

        def test_keeps_brand_abbr_when_logo_is_whitespace
          render_inline(Component.new(logo: "  ", brand_abbr: "AC", title: "Acme"))

          assert_text "AC"
          refute_selector "img"
        end

        def test_falls_back_to_abbr_when_logo_url_is_unsafe
          render_inline(Component.new(
            logo: "javascript:alert(1)",
            brand_abbr: "AC",
            title: "Acme"
          ))

          assert_text "AC"
          refute_selector "img"
          assert_no_match(/javascript/i, page.native.to_s)
        end

        def test_rejects_non_string_logo
          error = assert_raises(ArgumentError) do
            Component.new(logo: {src: "https://example.com/mark.png"})
          end

          assert_match(/logo:/, error.message)
          assert_match(/URL string/, error.message)
        end

        def test_accepts_safe_buffer_logo
          render_inline(Component.new(
            logo: ActiveSupport::SafeBuffer.new("https://example.com/mark.png"),
            brand_abbr: "AC",
            title: "Acme",
            show_version: false,
            collapsible: false
          ))

          assert_selector "img[src='https://example.com/mark.png']"
          assert_no_text "AC"
        end

        def test_hides_version_when_mark_is_present_and_show_version_false
          render_inline(Component.new(
            logo: "https://example.com/mark.png",
            title: "Acme",
            show_version: false
          ))

          assert_selector "img[src='https://example.com/mark.png']"
          assert_text "Acme"
          assert_no_text "v#{FlatPack::VERSION}"
          assert_no_selector "[data-flat-pack--sidebar-layout-target='headerLabel'] > span"
        end

        def test_content_block_still_replaces_chrome_when_logo_is_passed
          render_inline(Component.new(logo: "https://example.com/mark.png", title: "Acme")) { "Custom chrome" }

          assert_text "Custom chrome"
          assert_no_text "Acme"
          refute_selector "img"
          refute_selector "[data-flat-pack--sidebar-layout-target='collapsedToggle']"
          refute_selector "[data-flat-pack--sidebar-layout-target='desktopToggle']"
          refute_selector "[data-flat-pack--sidebar-layout-target='headerBrand']"
        end
      end
    end
  end
end
