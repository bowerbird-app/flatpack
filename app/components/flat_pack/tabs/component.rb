# frozen_string_literal: true

module FlatPack
  module Tabs
    class Component < FlatPack::BaseComponent
      def initialize(
        default_tab: 0,
        **system_arguments
      )
        super(**system_arguments)
        @default_tab = default_tab
        @tabs = []
        @panels = []
      end

      def tab(label:, id:, **tab_args)
        @tabs << {label: label, id: id, args: tab_args}
      end

      def panel(id:, &block)
        @panels << {id: id, content: capture(&block)}
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_tab_list,
            render_panels
          ])
        end
      end

      private

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--tabs",
            "flat-pack--tabs-default-value": @default_tab
          }
        )
      end

      def render_tab_list
        content_tag(:div,
          role: "tablist",
          aria: {label: "Tabs"},
          class: tab_list_classes
        ) do
          safe_join(@tabs.map.with_index { |tab, index| render_tab(tab, index) })
        end
      end

      def render_tab(tab, index)
        is_default = index == @default_tab

        content_tag(:button,
          tab[:label],
          type: "button",
          role: "tab",
          id: tab_id(tab[:id]),
          class: tab_classes(is_default),
          aria: {
            selected: is_default,
            controls: panel_id(tab[:id])
          },
          data: {
            "flat-pack--tabs-target": "tab",
            action: "flat-pack--tabs#selectTab"
          },
          tabindex: is_default ? 0 : -1
        )
      end

      def render_panels
        content_tag(:div, class: "mt-4") do
          safe_join(@panels.map.with_index { |panel, index| render_panel(panel, index) })
        end
      end

      def render_panel(panel, index)
        is_default = index == @default_tab

        # SECURITY: Panel content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components captured via block. Never pass
        # unsanitized user input directly to panel content.
        content_tag(:div,
          panel[:content].html_safe,
          id: panel_id(panel[:id]),
          role: "tabpanel",
          aria: {labelledby: tab_id(panel[:id])},
          class: panel_classes,
          data: {"flat-pack--tabs-target": "panel"},
          hidden: !is_default
        )
      end

      def tab_list_classes
        "flex gap-1 border-b border-[var(--color-border)]"
      end

      def tab_classes(is_active)
        base = "px-4 py-2 text-sm font-medium rounded-t-[var(--radius-md)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2"
        
        if is_active
          "#{base} bg-[var(--color-background)] text-[var(--color-primary)] border-b-2 border-[var(--color-primary)] -mb-px"
        else
          "#{base} text-[var(--color-text-muted)] hover:text-[var(--color-text)] hover:bg-[var(--color-muted)]"
        end
      end

      def panel_classes
        "focus:outline-none"
      end

      def tab_id(id)
        "#{id}-tab"
      end

      def panel_id(id)
        "#{id}-panel"
      end
    end
  end
end
