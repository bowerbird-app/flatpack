# frozen_string_literal: true

module FlatPack
  module Layout
    class Component < FlatPack::BaseComponent
      renders_one :sidebar, lambda { |collapsed: false, expanded_width: "256px", collapsed_width: "64px"|
        SidebarComponent.new(
          collapsed: collapsed,
          expanded_width: expanded_width,
          collapsed_width: collapsed_width
        )
      }

      renders_one :top_nav, lambda { |height: "64px"|
        TopNavComponent.new(height: height)
      }

      def initialize(**system_arguments)
        super
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            sidebar,
            content_tag(:div, class: "flex flex-col flex-1") do
              safe_join([top_nav, content_tag(:main, content, class: main_classes)].compact)
            end
          ].compact)
        end
      end

      private

      def wrapper_attributes
        merge_attributes(
          class: wrapper_classes,
          data: {
            controller: "flat-pack--layout",
            flat_pack__layout_expanded_width_value: "256px",
            flat_pack__layout_collapsed_width_value: "64px",
            flat_pack__layout_collapsed_value: false
          }
        )
      end

      def wrapper_classes
        classes(
          "flex",
          "h-full",
          "bg-[var(--color-background)]"
        )
      end

      def main_classes
        "flex-1 overflow-auto"
      end
    end
  end
end
