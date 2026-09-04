# frozen_string_literal: true

module FlatPack
  module TopNav
    class Component < FlatPack::BaseComponent
      renders_one :left_slot
      renders_one :center_slot
      renders_one :right_slot

      undef_method :with_left_slot, :with_left_slot_content,
        :with_center_slot, :with_center_slot_content,
        :with_right_slot, :with_right_slot_content

      SECTIONS = %w[left center right].freeze

      # Sections collapse into the mobile menu unless they opt out. `left` keeps
      # branding and the sidebar toggle inline, so it stays visible by default.
      DEFAULT_ALWAYS_DISPLAY = {
        "left" => true,
        "center" => false,
        "right" => false
      }.freeze

      TOGGLE_OPEN_CLASS = "[&>svg]:rotate-180"

      def initialize(
        mobile_menu: true,
        mobile_menu_label: "More navigation items",
        mobile_breakpoint: 768,
        **system_arguments
      )
        super(**system_arguments)
        @mobile_menu = mobile_menu
        @mobile_menu_label = mobile_menu_label
        @mobile_breakpoint = mobile_breakpoint.to_i
        @always_display = DEFAULT_ALWAYS_DISPLAY.dup
        @menu_id = "flat-pack-top-nav-menu-#{object_id}"
      end

      def left(always_display: nil, **args, &block)
        return left_slot unless block

        assign_always_display("left", always_display)
        set_slot(:left_slot, nil, **args, &block)
      end

      def center(always_display: nil, **args, &block)
        return center_slot unless block

        assign_always_display("center", always_display)
        set_slot(:center_slot, nil, **args, &block)
      end

      def right(always_display: nil, **args, &block)
        return right_slot unless block

        assign_always_display("right", always_display)
        set_slot(:right_slot, nil, **args, &block)
      end

      def left?
        left_slot?
      end

      def center?
        center_slot?
      end

      def right?
        right_slot?
      end

      def call
        content_tag(:header, **header_attributes) do
          content_tag(:div, class: container_classes) do
            safe_join([
              render_section(left, "left"),
              render_section(center, "center"),
              render_section(right, "right"),
              render_mobile_menu
            ].compact)
          end
        end
      end

      private

      def assign_always_display(section, value)
        return if value.nil?

        @always_display[section] = !!value
      end

      def collapsible?(section)
        @mobile_menu && !@always_display.fetch(section, false)
      end

      def render_section(slot_content, alignment)
        content_tag(
          :div,
          slot_content.to_s,
          class: section_classes(alignment),
          data: section_data(alignment)
        )
      end

      def section_data(alignment)
        return {} unless @mobile_menu

        {
          "flat-pack--top-nav-target": "section",
          "flat-pack-top-nav-section": alignment,
          "flat-pack-top-nav-collapsible": collapsible?(alignment).to_s
        }
      end

      # Rendered hidden and revealed by the Stimulus controller only when the
      # viewport is narrow and collapsible content was actually moved in, so
      # desktop and no-JS rendering are unchanged.
      def render_mobile_menu
        return unless @mobile_menu

        content_tag(
          :div,
          class: "hidden relative ml-auto shrink-0 items-center",
          data: {"flat-pack--top-nav-target": "menu"}
        ) do
          safe_join([render_mobile_menu_toggle, render_mobile_menu_panel])
        end
      end

      def render_mobile_menu_toggle
        render FlatPack::Button::Component.new(
          icon: "chevron-down",
          icon_only: true,
          style: :ghost,
          size: :md,
          aria: {label: @mobile_menu_label, expanded: "false", controls: @menu_id},
          data: {
            "flat-pack--top-nav-target": "toggle",
            action: "click->flat-pack--top-nav#toggle"
          },
          class: "border-0 shadow-none text-[var(--top-nav-item-icon-color)] hover:bg-[var(--top-nav-item-hover-background-color)] hover:text-[var(--top-nav-item-hover-text-color)] transition-colors [&>svg]:transition-transform [&>svg]:duration-[var(--duration-base)]"
        )
      end

      def render_mobile_menu_panel
        content_tag(
          :div,
          "",
          id: @menu_id,
          hidden: true,
          class: mobile_menu_panel_classes,
          aria: {label: @mobile_menu_label},
          data: {"flat-pack--top-nav-target": "panel"}
        )
      end

      def mobile_menu_panel_classes
        [
          "absolute right-0 top-full z-20 mt-2",
          "w-[min(20rem,calc(100vw-2rem))]",
          "flex flex-col items-stretch gap-3",
          "rounded-[var(--radius-lg)] border border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)] p-3 shadow-lg"
        ].join(" ")
      end

      def header_attributes
        attrs = merge_attributes(
          class: header_classes,
          style: header_style
        )

        return attrs unless @mobile_menu

        attrs[:data] = merge_data_attributes(
          attrs[:data],
          {
            controller: "flat-pack--top-nav",
            "flat-pack--top-nav-breakpoint-value": @mobile_breakpoint,
            "flat-pack--top-nav-toggle-open-class": TOGGLE_OPEN_CLASS
          }
        )

        attrs
      end

      def header_style
        existing_style = @system_arguments[:style]
        [existing_style, "height: 72px"].compact.join("; ")
      end

      def header_classes
        classes(
          "sticky",
          "top-0",
          "z-10",
          "bg-[var(--top-nav-background-color)]",
          "backdrop-blur-lg",
          "px-4",
          "py-0"
        )
      end

      def container_classes
        "h-full flex items-center gap-4"
      end

      def section_classes(alignment)
        case alignment
        when "left"
          "h-full min-w-[30%] flex items-center gap-2"
        when "center"
          "h-full min-w-[30%] flex-1 flex items-center justify-center"
        when "right"
          "h-full min-w-[30%] flex items-center justify-end gap-2"
        end
      end
    end
  end
end
