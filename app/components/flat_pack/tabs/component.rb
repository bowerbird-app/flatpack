# frozen_string_literal: true

module FlatPack
  module Tabs
    class Component < FlatPack::BaseComponent
      SIZES = FlatPack::Shared::PadTextSizes::SIZES
      STYLES = FlatPack::Button::StyleRegistry::BUILT_IN

      VARIANTS = {
        underline: {
          tab_list: "flex gap-1 border-b border-[var(--surface-border-color)]",
          tab_base: "font-medium rounded-t-[var(--radius-md)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring focus-visible:ring-offset-2",
          active: "bg-[var(--surface-background-color)] text-primary border-b-2 border-primary -mb-px",
          inactive: "text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)] hover:bg-[var(--surface-muted-background-color)]"
        },
        pills: {
          tab_list: "inline-flex gap-1 [border-radius:var(--tabs-pill-corner-radius)] p-1",
          tab_base: "border border-transparent font-medium [border-radius:var(--tabs-pill-corner-radius)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring focus-visible:ring-offset-2",
          active: FlatPack::Button::PillStyle::ACTIVE_CLASSES,
          inactive: FlatPack::Button::PillStyle::INACTIVE_CLASSES
        },
        stacked: {
          tab_list: "flex flex-col gap-1 [border-radius:1.5rem] p-2 bg-[var(--tabs-stacked-pill-list-background-color)] border border-[var(--tabs-pill-list-border-color)]",
          tab_base: "w-full [border-radius:var(--tabs-pill-corner-radius)] text-left font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring focus-visible:ring-offset-2",
          active: "border #{FlatPack::Button::PillStyle::ACTIVE_CLASSES}",
          inactive: "border #{FlatPack::Button::PillStyle::INACTIVE_CLASSES}"
        }
      }.freeze

      UNDERLINE_SLIDE_ACTIVE_TEXT = "text-primary"
      UNDERLINE_SLIDE_INACTIVE_TEXT = "text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)]"

      def initialize(
        default_tab: 0,
        variant: :underline,
        size: :md,
        style: FlatPack::Button::PillStyle::DEFAULT,
        indicator: nil,
        **system_arguments
      )
        super(**system_arguments)
        @default_tab = default_tab
        @variant = variant.to_sym
        @size = FlatPack::Shared::PadTextSizes.normalize!(size)
        @pill_style = FlatPack::Button::PillStyle.resolve(style)
        @indicator = FlatPack::Shared::SlideIndicator.normalize(indicator)
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
        content_tag(:div, **tab_list_attributes) do
          nodes = []
          nodes << render_slide_indicator if sliding_indicator?
          nodes.concat(@tabs.map.with_index { |tab, index| render_tab(tab, index) })
          safe_join(nodes)
        end
      end

      def render_slide_indicator
        content_tag(
          :span,
          "",
          class: FlatPack::Shared::SlideIndicator.indicator_classes(kind: slide_indicator_kind),
          aria: {hidden: true},
          data: {"flat-pack--slide-indicator-target": "indicator"}
        )
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
          data: tab_data_attributes,
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

      def tab_list_attributes
        attributes = {
          role: "tablist",
          aria: tab_list_aria_attributes,
          class: tab_list_classes
        }
        unless pill_list?
          return sliding_indicator? ? with_slide_indicator(attributes) : attributes
        end

        pill_attributes = attributes.merge(
          class: "#{tab_list_classes} #{@pill_style.group_class}",
          data: {fp_style: @pill_style.name.to_s}
        )
        return pill_attributes unless sliding_indicator?

        with_slide_indicator(pill_attributes)
      end

      def with_slide_indicator(attributes)
        attributes.merge(
          class: "#{attributes[:class]} #{FlatPack::Shared::SlideIndicator::LIST_CLASS}",
          data: merge_data_attributes(attributes[:data], FlatPack::Shared::SlideIndicator.list_data(kind: slide_indicator_kind))
        )
      end

      def pill_list?
        @variant == :pills || @variant == :stacked
      end

      def tab_classes(is_active)
        [
          FlatPack::Shared::PadTextSizes.classes_for(@size),
          variant_classes.fetch(:tab_base),
          ("border border-transparent" if sliding_indicator? && @variant == :stacked),
          (FlatPack::Shared::SlideIndicator::ITEM_CLASS if sliding_indicator?),
          is_active ? active_tab_classes : inactive_tab_classes
        ].compact.join(" ")
      end

      def tab_data_attributes
        data = {
          "flat-pack--tabs-target": "tab",
          action: "flat-pack--tabs#selectTab",
          "flat-pack-tabs-active-classes": active_tab_classes,
          "flat-pack-tabs-inactive-classes": inactive_tab_classes
        }
        return data unless sliding_indicator?

        merge_data_attributes(data, FlatPack::Shared::SlideIndicator.item_data)
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
          label: fp_t("tabs.label"),
          orientation: tab_orientation
        }
      end

      def active_tab_classes
        return slide_active_text_classes if sliding_indicator?

        variant_classes.fetch(:active)
      end

      def inactive_tab_classes
        return slide_inactive_text_classes if sliding_indicator?

        variant_classes.fetch(:inactive)
      end

      def slide_active_text_classes
        return UNDERLINE_SLIDE_ACTIVE_TEXT if @variant == :underline

        FlatPack::Button::PillStyle::ACTIVE_TEXT_CLASSES
      end

      def slide_inactive_text_classes
        return UNDERLINE_SLIDE_INACTIVE_TEXT if @variant == :underline

        FlatPack::Button::PillStyle::INACTIVE_TEXT_CLASSES
      end

      def sliding_indicator?
        @indicator == :slide
      end

      def slide_indicator_kind
        (@variant == :underline) ? FlatPack::Shared::SlideIndicator::KIND_UNDERLINE : FlatPack::Shared::SlideIndicator::KIND_PILL
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end
    end
  end
end
