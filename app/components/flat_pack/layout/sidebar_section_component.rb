# frozen_string_literal: true

module FlatPack
  module Layout
    class SidebarSectionComponent < FlatPack::BaseComponent
      renders_many :items, SidebarItemComponent

      def initialize(title: nil, collapsible: false, collapsed: false, **system_arguments)
        super(**system_arguments)
        @title = title
        @collapsible = collapsible
        @collapsed = collapsed
      end

      def call
        content_tag(:div, class: "mb-6") do
          safe_join([
            render_title,
            content_tag(:ul, class: items_list_classes) do
              safe_join(items.map { |item| content_tag(:li, item) })
            end
          ].compact)
        end
      end

      private

      def render_title
        return unless @title

        if @collapsible
          content_tag(:button, **title_button_attributes) do
            safe_join([
              content_tag(:span, @title, class: "flex-1 text-left"),
              chevron_icon
            ])
          end
        else
          content_tag(:h3, @title, class: title_classes, data: {flat_pack__layout_target: "sectionTitle"})
        end
      end

      def title_button_attributes
        {
          type: "button",
          class: "flex items-center gap-2 w-full px-3 py-2 mb-2 text-xs font-semibold uppercase tracking-wider text-[var(--color-muted-foreground)] hover:text-[var(--color-foreground)] transition-colors",
          data: {
            action: "click->flat-pack--sidebar#toggleSection",
            flat_pack__layout_target: "sectionTitle"
          }
        }
      end

      def title_classes
        "px-3 py-2 mb-2 text-xs font-semibold uppercase tracking-wider text-[var(--color-muted-foreground)]"
      end

      def chevron_icon
        content_tag(:svg, **chevron_attributes) do
          content_tag(:path, nil, d: "m9 18 6-6-6-6")
        end
      end

      def chevron_attributes
        {
          xmlns: "http://www.w3.org/2000/svg",
          width: "16",
          height: "16",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          class: chevron_classes
        }
      end

      def chevron_classes
        classes(
          "transition-transform duration-200",
          @collapsed ? "" : "rotate-180"
        )
      end

      def items_list_classes
        classes(
          "space-y-1",
          @collapsible && @collapsed ? "hidden" : ""
        )
      end
    end
  end
end
