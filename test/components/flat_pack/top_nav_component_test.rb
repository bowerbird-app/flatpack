# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TopNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_basic_top_nav
        render_inline(Component.new)
        assert_selector "header"
      end

      def test_renders_left_slot
        render_inline(Component.new) do |nav|
          nav.left do
            "Left content"
          end
        end
        assert_text "Left content"
      end

      def test_renders_center_slot
        render_inline(Component.new) do |nav|
          nav.center do
            "Center content"
          end
        end
        assert_text "Center content"
      end

      def test_renders_right_slot
        render_inline(Component.new) do |nav|
          nav.right do
            "Right content"
          end
        end
        assert_text "Right content"
      end

      def test_renders_all_slots
        render_inline(Component.new) do |nav|
          nav.left { "Left" }
          nav.center { "Center" }
          nav.right { "Right" }
        end
        assert_text "Left"
        assert_text "Center"
        assert_text "Right"
      end

      def test_renders_all_wrappers_when_left_is_uninitialized
        render_inline(Component.new) do |nav|
          nav.center { "Center content" }
          nav.right { "Right content" }
        end

        sections = rendered_section_nodes

        assert_equal 3, sections.size
        assert_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-[30%]"
        assert_includes sections[2]["class"], "min-w-[30%]"
        assert_includes sections[0]["class"], "gap-2"
        assert_includes sections[1]["class"], "flex-1"
        assert_includes sections[2]["class"], "gap-2"
        assert_includes sections[2]["class"], "justify-end"
        assert_equal "", sections[0].text.strip
        assert_equal "Center content", sections[1].text.strip
        assert_equal "Right content", sections[2].text.strip
      end

      def test_renders_all_wrappers_when_center_is_uninitialized
        render_inline(Component.new) do |nav|
          nav.left { "Left content" }
          nav.right { "Right content" }
        end

        sections = rendered_section_nodes

        assert_equal 3, sections.size
        assert_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-[30%]"
        assert_includes sections[2]["class"], "min-w-[30%]"
        assert_includes sections[0]["class"], "gap-2"
        assert_includes sections[1]["class"], "flex-1"
        assert_includes sections[2]["class"], "gap-2"
        assert_includes sections[2]["class"], "justify-end"
        assert_equal "Left content", sections[0].text.strip
        assert_equal "", sections[1].text.strip
        assert_equal "Right content", sections[2].text.strip
      end

      def test_renders_all_wrappers_when_right_is_uninitialized
        render_inline(Component.new) do |nav|
          nav.left { "Left content" }
          nav.center { "Center content" }
        end

        sections = rendered_section_nodes

        assert_equal 3, sections.size
        assert_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-[30%]"
        assert_includes sections[2]["class"], "min-w-[30%]"
        assert_includes sections[0]["class"], "gap-2"
        assert_includes sections[1]["class"], "flex-1"
        assert_includes sections[2]["class"], "gap-2"
        assert_includes sections[2]["class"], "justify-end"
        assert_equal "Left content", sections[0].text.strip
        assert_equal "Center content", sections[1].text.strip
        assert_equal "", sections[2].text.strip
      end

      def test_has_sticky_positioning
        render_inline(Component.new)
        assert_includes page.native.to_html, "sticky"
        assert_includes page.native.to_html, "top-0"
      end

      def test_has_backdrop_blur
        render_inline(Component.new)
        assert_includes page.native.to_html, "backdrop-blur"
      end

      def test_has_no_border
        render_inline(Component.new)
        html = page.native.to_html
        refute_includes html, "border-b"
        refute_includes html, "top-nav-border-color"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-nav"))
        assert_includes page.native.to_html, "custom-nav"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "top-nav"}))
        assert_selector "header[data-testid='top-nav']"
      end

      def test_registers_mobile_menu_controller_by_default
        render_inline(Component.new)

        assert_selector "header[data-controller~='flat-pack--top-nav']"
        assert_selector "header[data-flat-pack--top-nav-breakpoint-value='768']"
      end

      def test_mobile_menu_controller_preserves_host_controllers
        render_inline(Component.new(data: {controller: "host--analytics"}))

        assert_selector "header[data-controller~='host--analytics']"
        assert_selector "header[data-controller~='flat-pack--top-nav']"
      end

      def test_accepts_custom_mobile_breakpoint
        render_inline(Component.new(mobile_breakpoint: 1024))

        assert_selector "header[data-flat-pack--top-nav-breakpoint-value='1024']"
      end

      def test_renders_mobile_menu_toggle_and_panel
        render_inline(Component.new(mobile_menu_label: "Open navigation"))

        assert_selector "[data-flat-pack--top-nav-target='menu']", visible: :all
        assert_selector "[data-flat-pack--top-nav-target='toggle'][aria-label='Open navigation']", visible: :all
        assert_selector "[data-flat-pack--top-nav-target='panel'][hidden]", visible: :all
      end

      def test_mobile_menu_toggle_controls_panel
        render_inline(Component.new)

        toggle = page.native.at_css("[data-flat-pack--top-nav-target='toggle']")
        panel = page.native.at_css("[data-flat-pack--top-nav-target='panel']")

        assert_equal panel["id"], toggle["aria-controls"]
        assert_equal "false", toggle["aria-expanded"]
      end

      def test_left_section_is_always_displayed_by_default
        render_inline(Component.new) do |nav|
          nav.left { "Brand" }
          nav.center { "Search" }
          nav.right { "Actions" }
        end

        assert_equal "false", section_for("left")["data-flat-pack-top-nav-collapsible"]
        assert_equal "true", section_for("center")["data-flat-pack-top-nav-collapsible"]
        assert_equal "true", section_for("right")["data-flat-pack-top-nav-collapsible"]
      end

      def test_always_display_opts_sections_out_of_the_mobile_menu
        render_inline(Component.new) do |nav|
          nav.left(always_display: false) { "Brand" }
          nav.center(always_display: true) { "Search" }
          nav.right(always_display: true) { "Actions" }
        end

        assert_equal "true", section_for("left")["data-flat-pack-top-nav-collapsible"]
        assert_equal "false", section_for("center")["data-flat-pack-top-nav-collapsible"]
        assert_equal "false", section_for("right")["data-flat-pack-top-nav-collapsible"]
      end

      def test_mobile_menu_toggle_icon_rotates_while_open
        render_inline(Component.new)

        toggle = page.native.at_css("[data-flat-pack--top-nav-target='toggle']")

        assert_includes toggle["class"], "[&>svg]:transition-transform"
        assert_includes toggle["class"], "[&>svg]:duration-[var(--duration-base)]"
        refute_includes toggle["class"], "[&>svg]:rotate-180"

        assert_selector "header[data-flat-pack--top-nav-toggle-open-class='[&>svg]:rotate-180']"
      end

      def test_mobile_menu_can_be_disabled
        render_inline(Component.new(mobile_menu: false)) do |nav|
          nav.center { "Search" }
        end

        refute_selector "[data-flat-pack--top-nav-target='menu']", visible: :all
        refute_includes page.native.to_html, "flat-pack--top-nav"
        assert_text "Search"
      end

      private

      def section_for(alignment)
        page.native.at_css("[data-flat-pack-top-nav-section='#{alignment}']")
      end

      def rendered_section_nodes
        container = page.native.at_css("header > div")
        return [] unless container

        container.xpath("./div[@data-flat-pack-top-nav-section]")
      end
    end
  end
end
