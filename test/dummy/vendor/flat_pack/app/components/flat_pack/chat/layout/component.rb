# frozen_string_literal: true

module FlatPack
  module Chat
    module Layout
      class Component < FlatPack::BaseComponent
        renders_one :sidebar
        renders_one :panel

        undef_method :with_sidebar, :with_sidebar_content
        undef_method :with_panel, :with_panel_content

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "flex" "flex-col" "min-w-0" "hidden" "md:block"
        # "sm:grid" "sm:flex" "sm:hidden" "sm:border-b-0" "sm:border-r"
        # "md:grid" "md:flex" "md:hidden" "md:border-b-0" "md:border-r"
        # "lg:grid" "lg:flex" "lg:hidden" "lg:border-b-0" "lg:border-r"
        VARIANTS = %i[single split].freeze

        SPLIT_BREAKPOINTS = {
          sm: {
            min_width: 640,
            grid: "sm:grid",
            panel: "hidden sm:flex",
            sidebar_divider: "sm:border-b-0 sm:border-r",
            stacked_only: "sm:hidden"
          },
          md: {
            min_width: 768,
            grid: "md:grid",
            panel: "hidden md:flex",
            sidebar_divider: "md:border-b-0 md:border-r",
            stacked_only: "md:hidden"
          },
          lg: {
            min_width: 1024,
            grid: "lg:grid",
            panel: "hidden lg:flex",
            sidebar_divider: "lg:border-b-0 lg:border-r",
            stacked_only: "lg:hidden"
          }
        }.freeze

        # A capped proportional track. A plain 16rem sidebar holds its width and
        # makes the thread absorb every reduction, which is the squeeze a fixed
        # 280px caused. 30% keeps the thread the larger column on a narrow desk,
        # and the cap stops the list sprawling on a wide one.
        DEFAULT_SIDEBAR_WIDTH = "clamp(12rem, 30%, 16rem)"
        PANEL_TRACK = "minmax(0, 1fr)"

        def initialize(
          variant: :single,
          split_breakpoint: :sm,
          sidebar_width: DEFAULT_SIDEBAR_WIDTH,
          **system_arguments
        )
          super(**system_arguments)
          @variant = variant.to_sym
          @split_breakpoint = split_breakpoint.to_sym
          @sidebar_width = sidebar_width

          validate_variant!
          validate_split_breakpoint!
          @sidebar_width = validated_sidebar_width!
        end

        def sidebar(*args, **kwargs, &block)
          return get_slot(:sidebar) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:sidebar, nil, *args, **kwargs, &block)
        end

        def panel(*args, **kwargs, &block)
          return get_slot(:panel) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:panel, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **layout_attributes) do
            safe_join([
              (render_sidebar if sidebar?),
              (render_panel if panel?)
            ].compact)
          end
        end

        private

        def render_sidebar
          content_tag(:div, class: sidebar_classes, data: sidebar_data_attributes) do
            sidebar.to_s
          end
        end

        def render_panel
          content_tag(:div, class: panel_classes, data: panel_data_attributes) do
            safe_join([
              render_mobile_back_action,
              panel.to_s
            ].compact)
          end
        end

        def layout_attributes
          merge_attributes(
            class: layout_classes,
            data: merge_data_attributes(data_attributes, layout_data_attributes),
            style: layout_style
          )
        end

        def layout_classes
          classes(
            "h-full",
            "min-h-0",
            "border border-[var(--chat-border-color)]",
            "rounded-[var(--radius-lg)]",
            "overflow-hidden",
            "bg-[var(--chat-background-color)]",
            "flex flex-col",
            (breakpoint_classes.fetch(:grid) if split?)
          )
        end

        # The split columns are fluid, so they are set as a style rather than as a
        # Tailwind arbitrary value that would have to be a literal per width.
        # Below the breakpoint the layout is a flex column, where the tracks are inert.
        def layout_style
          declarations = [split_columns_declaration, caller_style].compact
          return nil if declarations.empty?

          declarations.join("; ")
        end

        def split_columns_declaration
          return unless split?

          "grid-template-columns: #{@sidebar_width} #{PANEL_TRACK}"
        end

        def caller_style
          style = html_attributes[:style] || html_attributes["style"]
          style = style.to_s.strip.delete_suffix(";").strip
          style.presence
        end

        def sidebar_classes
          classes(
            "h-full min-h-0 min-w-0",
            "border-b border-[var(--chat-border-color)]",
            (breakpoint_classes.fetch(:sidebar_divider) if split?),
            "bg-[var(--chat-background-color)]",
            "overflow-y-auto"
          )
        end

        def panel_classes
          classes(
            panel_visibility_classes,
            "flex-col",
            "h-full min-h-0 min-w-0",
            "overflow-hidden"
          )
        end

        def panel_visibility_classes
          return "flex" unless stacked_split_layout?

          breakpoint_classes.fetch(:panel)
        end

        # A split layout stacks into list-then-panel below the breakpoint, which only
        # makes sense when there is both a list to leave and a panel to open.
        def stacked_split_layout?
          split? && sidebar? && panel?
        end

        def split?
          @variant == :split
        end

        def breakpoint_classes
          SPLIT_BREAKPOINTS.fetch(@split_breakpoint)
        end

        def layout_data_attributes
          return {} unless stacked_split_layout?

          {
            controller: "flat-pack--chat-layout",
            flat_pack__chat_layout_breakpoint_value: breakpoint_classes.fetch(:min_width)
          }
        end

        def sidebar_data_attributes
          return {} unless stacked_split_layout?

          {
            flat_pack__chat_layout_target: "sidebar",
            action: "click->flat-pack--chat-layout#openPanel"
          }
        end

        def panel_data_attributes
          return {} unless stacked_split_layout?

          {
            flat_pack__chat_layout_target: "panel"
          }
        end

        def render_mobile_back_action
          return unless stacked_split_layout?

          content_tag(:div, class: mobile_back_container_classes) do
            render FlatPack::Button::Component.new(
              text: "Back",
              icon: "chevron-left",
              style: :ghost,
              size: :sm,
              type: "button",
              data: {action: "click->flat-pack--chat-layout#showSidebar"},
              aria: {label: "Back to conversations"}
            )
          end
        end

        def mobile_back_container_classes
          classes(
            "flex flex-shrink-0 items-center border-b border-[var(--chat-header-border-color)] bg-[var(--chat-header-background-color)] p-2",
            breakpoint_classes.fetch(:stacked_only)
          )
        end

        def validate_variant!
          return if VARIANTS.include?(@variant)
          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
        end

        def validate_split_breakpoint!
          return if SPLIT_BREAKPOINTS.key?(@split_breakpoint)
          raise ArgumentError, "Invalid split_breakpoint: #{@split_breakpoint}. Must be one of: #{SPLIT_BREAKPOINTS.keys.join(", ")}"
        end

        def validated_sidebar_width!
          track = FlatPack::AttributeSanitizer.sanitize_css_grid_track(@sidebar_width)
          return track if track

          raise ArgumentError, "Invalid sidebar_width: #{@sidebar_width.inspect}. Must be a CSS grid track such as \"#{DEFAULT_SIDEBAR_WIDTH}\" or \"12rem\"."
        end
      end
    end
  end
end
