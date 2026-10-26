# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TopNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_basic_top_nav
        render_inline(Component.new)
        assert_selector "header"
        assert_includes page.native.to_html, "fp-top-nav"
        refute_includes page.native.to_html, "height: 72px"
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
        refute_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-0"
        refute_includes sections[2]["class"], "min-w-[30%]"
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
        refute_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-0"
        refute_includes sections[2]["class"], "min-w-[30%]"
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
        refute_includes sections[0]["class"], "min-w-[30%]"
        assert_includes sections[1]["class"], "min-w-0"
        refute_includes sections[2]["class"], "min-w-[30%]"
        assert_includes sections[0]["class"], "gap-2"
        assert_includes sections[1]["class"], "flex-1"
        assert_includes sections[2]["class"], "gap-2"
        assert_includes sections[2]["class"], "justify-end"
        assert_equal "Left content", sections[0].text.strip
        assert_equal "Center content", sections[1].text.strip
        assert_equal "", sections[2].text.strip
      end

      def test_is_a_layout_row_without_bar_chrome
        render_inline(Component.new)
        html = page.native.to_html

        assert_includes html, "fp-top-nav"
        refute_includes html, "sticky"
        refute_includes html, "top-0"
        refute_includes html, "top-nav-background-color"
        refute_includes html, "backdrop-blur"
        refute_includes html, "data-scrolled"
        refute_includes html, "flat-pack--top-nav"
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

      def test_keeps_a_host_controller_and_does_not_add_frost
        render_inline(Component.new(data: {controller: "host--analytics"}))

        assert_selector "header[data-controller='host--analytics']"
        refute_selector "header[data-controller~='flat-pack--top-nav']"
        refute_selector "header[data-scrolled]", visible: :all
      end

      def test_is_a_row_with_no_menu_of_its_own
        render_inline(Component.new) do |nav|
          nav.left { "Brand" }
          nav.center { "Search" }
          nav.right { "Bell" }
        end

        html = page.native.to_html

        assert_selector ".fp-top-nav__left", text: "Brand"
        assert_selector ".fp-top-nav__center", text: "Search"
        assert_selector ".fp-top-nav__right", text: "Bell"
        refute_includes html, "data-flat-pack-top-nav-section"
        assert_includes section_for("left")["class"], "min-w-0"
        assert_includes section_for("center")["class"], "min-w-0"
        assert_includes section_for("right")["class"], "min-w-0"
        refute_includes html, "flat-pack--top-nav-target"
        refute_includes html, "data-flat-pack-top-nav-collapsible"
        refute_includes html, "data-flat-pack-top-nav-always-display"
        refute_selector "[role='menu']", visible: :all
      end

      def test_rejects_the_removed_menu_options
        error = assert_raises(ArgumentError) { Component.new(mobile_menu: false) }

        assert_match(/unknown keyword: :?mobile_menu/, error.message)
        assert_raises(ArgumentError) { Component.new(mobile_menu_label: "Menu") }
        assert_raises(ArgumentError) { Component.new(mobile_breakpoint: 1024) }
      end

      def test_default_padding_marks_the_row
        render_inline(Component.new)

        assert_selector "header.fp-top-nav[data-fp-top-nav-padding='default']"
        assert_selector "header.fp-top-nav[data-fp-top-nav-size='md']"
      end

      def test_large_size_marks_the_row
        render_inline(Component.new(size: :lg))

        assert_selector "header.fp-top-nav[data-fp-top-nav-size='lg'][data-fp-top-nav-padding='default']"
      end

      def test_default_size_alias_marks_medium
        render_inline(Component.new(size: :default))

        assert_selector "header.fp-top-nav[data-fp-top-nav-size='md']"
      end

      def test_size_accepts_the_string_form
        render_inline(Component.new(size: "lg"))

        assert_selector "[data-fp-top-nav-size='lg']"
      end

      def test_size_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(size: :sm) }

        assert_equal "size must be :md, :lg, or :default", error.message
      end

      def test_padding_none_marks_the_row
        render_inline(Component.new(padding: :none))

        assert_selector "header.fp-top-nav[data-fp-top-nav-padding='none']"
      end

      def test_padding_accepts_the_string_form
        render_inline(Component.new(padding: "none"))

        assert_selector "[data-fp-top-nav-padding='none']"
      end

      def test_padding_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(padding: :compact) }

        assert_equal "padding must be :default or :none", error.message
      end

      def test_slots_reject_always_display
        render_inline(Component.new) do |nav|
          assert_raises(ArgumentError) { nav.left(always_display: true) { "Brand" } }
        end
      end

      private

      def section_for(alignment)
        page.native.at_css(".fp-top-nav__#{alignment}")
      end

      def rendered_section_nodes
        container = page.native.at_css("header > div")
        return [] unless container

        container.xpath("./div[contains(@class, 'fp-top-nav__section')]")
      end
    end
  end
end
