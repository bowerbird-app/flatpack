# frozen_string_literal: true

module FlatPack
  module Chat
    module Layout
      class Component < FlatPack::BaseComponent
        renders_one :sidebar
        renders_one :panel

        alias_method :sidebar_slot, :sidebar
        alias_method :panel_slot, :panel

        def sidebar(*args, &block)
          return with_sidebar(*args, &block) if block_given? || args.any?

          sidebar_slot
        end

        def panel(*args, &block)
          return with_panel(*args, &block) if block_given? || args.any?

          panel_slot
        end

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "flex" "flex-col" "grid" "grid-cols-[280px_1fr]"
        VARIANTS = {
          single: "flex flex-col",
          split: "grid grid-cols-[280px_1fr]"
        }.freeze

        def initialize(
          variant: :single,
          **system_arguments
        )
          super(**system_arguments)
          @variant = variant.to_sym

          validate_variant!
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
          content_tag(:div, class: sidebar_classes) do
            sidebar.to_s
          end
        end

        def render_panel
          content_tag(:div, class: panel_classes) do
            panel.to_s
          end
        end

        def layout_attributes
          merge_attributes(
            class: layout_classes
          )
        end

        def layout_classes
          classes(
            "h-full",
            "bg-[var(--chat-background-color)]",
            VARIANTS.fetch(@variant)
          )
        end

        def sidebar_classes
          classes(
            "border-r border-[var(--chat-border-color)]",
            "bg-[var(--chat-background-color)]",
            "overflow-y-auto"
          )
        end

        def panel_classes
          classes(
            "flex flex-col",
            "h-full",
            "overflow-hidden"
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
