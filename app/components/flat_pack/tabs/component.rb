# frozen_string_literal: true

module FlatPack
  module Tabs
    class Component < FlatPack::BaseComponent
      VARIANTS = {
        underline: {
          tab_list: "flex gap-1 border-b border-[var(--surface-border-color)]",
          tab_base: "px-4 py-2 text-sm font-medium rounded-t-md transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          active: "bg-[var(--surface-background-color)] text-primary border-b-2 border-primary -mb-px",
          inactive: "text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)] hover:bg-[var(--surface-muted-background-color)]"
        },
        pills: {
          tab_list: "inline-flex gap-1 [border-radius:var(--tabs-pill-corner-radius)] border border-[var(--tabs-pill-list-border-color)] bg-[var(--tabs-pill-list-background-color)] p-1",
          tab_base: "border border-transparent px-4 py-2 text-sm font-medium [border-radius:var(--tabs-pill-corner-radius)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          active: "border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]",
          inactive: "text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]"
        },
        stacked: {
          tab_list: "flex flex-col gap-1 [border-radius:var(--tabs-pill-corner-radius)] border border-[var(--tabs-pill-list-border-color)] bg-[var(--tabs-stacked-pill-list-background-color)] p-1",
          tab_base: "w-full [border-radius:var(--tabs-pill-corner-radius)] px-3 py-2 text-left text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          active: "border border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]",
          inactive: "border border-transparent text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]"
        }
      }.freeze

      def initialize(
        default_tab: 0,
        variant: :underline,
        **system_arguments
      )
        super(**system_arguments)
        @default_tab = default_tab
        @variant = variant.to_sym
        @tabs = []
        @panels = []

        validate_variant!
      end

      def tab(label:, id:, **tab_args, &block)
        @tabs << {label: label, id: id, args: tab_args}

        if block
          @panels << {id: id, content: view_context.capture(&block)}
        end
      end

      def panel(id:, &block)
        @panels << {id: id, content: view_context.capture(&block)}
      end

      def call
        content

        content_tag(:div, **container_attributes) do
          content_tag(:div, class: layout_classes) do
            safe_join([
              render_tab_list,
              render_panels
            ])
          end
        end
      end

      private

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--tabs",
            "flat-pack--tabs-default-value": @default_tab,
            "flat-pack--tabs-orientation-value": tab_orientation
          }
        )
      end

      def render_tab_list
        content_tag(:div,
          role: "tablist",
          aria: tab_list_aria_attributes,
          class: tab_list_classes) do
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
            action: "flat-pack--tabs#selectTab",
            "flat-pack-tabs-active-classes": active_tab_classes,
            "flat-pack-tabs-inactive-classes": inactive_tab_classes
          },
          tabindex: is_default ? 0 : -1)
      end

      def render_panels
        content_tag(:div, class: panel_wrapper_classes) do
          safe_join(@panels.map.with_index { |panel, index| render_panel(panel, index) })
        end
      end

      def layout_classes
        return "flex flex-col gap-4 md:grid md:grid-cols-[16rem_minmax(0,1fr)] md:items-start md:gap-6" if @variant == :stacked

        ""
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
          hidden: !is_default)
      end

      def tab_list_classes
        variant_classes.fetch(:tab_list)
      end

      def tab_classes(is_active)
        [
          variant_classes.fetch(:tab_base),
          is_active ? active_tab_classes : inactive_tab_classes
        ].join(" ")
      end

      def panel_classes
        "focus:outline-none"
      end

      def panel_wrapper_classes
        return "md:min-w-0" if @variant == :stacked

        "mt-4"
      end

      def tab_id(id)
        "#{id}-tab"
      end

      def panel_id(id)
        "#{id}-panel"
      end

      def variant_classes
        VARIANTS.fetch(@variant)
      end

      def tab_orientation
        (@variant == :stacked) ? "vertical" : "horizontal"
      end

      def tab_list_aria_attributes
        {
          label: "Tabs",
          orientation: tab_orientation
        }
      end

      def active_tab_classes
        variant_classes.fetch(:active)
      end

      def inactive_tab_classes
        variant_classes.fetch(:inactive)
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end
    end
  end
end
