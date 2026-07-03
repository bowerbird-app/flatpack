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
        # "flex" "flex-col" "md:grid" "md:grid-cols-[280px_1fr]" "hidden" "md:block" "md:flex"
        VARIANTS = {
          single: "flex flex-col",
          split: "flex flex-col md:grid md:grid-cols-[280px_1fr]"
        }.freeze

        def initialize(
          variant: :single,
          **system_arguments
        )
          super(**system_arguments)
          @variant = variant.to_sym

          validate_variant!
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
            data: merge_data_attributes(data_attributes, layout_data_attributes)
          )
        end

        def layout_classes
          classes(
            "h-full",
            "min-h-0",
            "border border-[var(--chat-border-color)]",
            "rounded-lg",
            "overflow-hidden",
            "bg-[var(--chat-background-color)]",
            VARIANTS.fetch(@variant)
          )
        end

        def sidebar_classes
          classes(
            "h-full min-h-0",
            "border-b border-[var(--chat-border-color)] md:border-b-0 md:border-r",
            "bg-[var(--chat-background-color)]",
            "overflow-y-auto"
          )
        end

        def panel_classes
          classes(
            panel_visibility_classes,
            "flex-col",
            "h-full min-h-0",
            "overflow-hidden"
          )
        end

        def panel_visibility_classes
          return "flex" unless mobile_split_layout?

          "hidden md:flex"
        end

        def mobile_split_layout?
          @variant == :split && sidebar? && panel?
        end

        def layout_data_attributes
          return {} unless mobile_split_layout?

          {
            controller: "flat-pack--chat-layout"
          }
        end

        def sidebar_data_attributes
          return {} unless mobile_split_layout?

          {
            flat_pack__chat_layout_target: "sidebar",
            action: "click->flat-pack--chat-layout#openPanel"
          }
        end

        def panel_data_attributes
          return {} unless mobile_split_layout?

          {
            flat_pack__chat_layout_target: "panel"
          }
        end

        def render_mobile_back_action
          return unless mobile_split_layout?

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
            "flex flex-shrink-0 items-center border-b border-[var(--chat-header-border-color)] bg-[var(--chat-header-background-color)] p-2 md:hidden"
          )
        end

        def validate_variant!
          return if VARIANTS.key?(@variant)
          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
        end
      end
    end
  end
end
