# frozen_string_literal: true

module FlatPack
  module Chat
    module Layout
      class Component < FlatPack::BaseComponent
        renders_one :sidebar
        renders_one :panel

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
            sidebar
          end
        end

        def render_panel
          content_tag(:div, class: panel_classes) do
            panel
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
