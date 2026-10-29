# frozen_string_literal: true

module FlatPack
  module DatePicker
    # Internal picker surface shared by DateInput (custom picker) and DateRangeInput.
    # Hosts keep rendering those components. This panel is not a public field API.
    # Preset lists are passed in so DateRangeInput#quick_range_presets stays the
    # overridable method. Hosts should pass DateRangeInput presets: when they can.
    class Panel < FlatPack::BaseComponent
      def initialize(panel_id:, presets:, range:)
        super()
        @panel_id = panel_id
        @presets = presets
        @range = range
      end

      def call
        content_tag(:div, **picker_panel_attributes) do
          parts = [render_picker_quick_ranges, render_picker_calendar]
          parts << render_picker_actions if @range
          safe_join(parts)
        end
      end

      private

      def render_picker_quick_ranges
        buttons = @presets.map { |preset| render_quick_range_button(preset) }
        buttons << render_open_calendar_button if @range

        content_tag(:div, **quick_ranges_attributes) do
          safe_join([
            content_tag(:p, quick_ranges_heading, class: "text-xs font-semibold text-[var(--surface-muted-content-color)]"),
            content_tag(:div, class: "mt-2 space-y-1") do
              safe_join(buttons)
            end
          ])
        end
      end

      def quick_ranges_attributes
        attrs = {class: picker_ranges_section_classes}
        attrs[:data] = {"flat-pack--flatpack-date-picker-target": "listView"} if @range
        attrs
      end

      def quick_ranges_heading
        @range ? fp_t("date.range") : fp_t("date.quick_select")
      end

      def render_quick_range_button(preset)
        render(FlatPack::Button::Component.new(
          text: preset[:label],
          style: :ghost,
          size: :sm,
          type: "button",
          class: "w-full justify-start",
          data: {
            "flat-pack-date-picker-command": "preset",
            "flat-pack-date-picker-preset": preset[:key]
          }
        ))
      end

      def render_open_calendar_button
        render(FlatPack::Button::Component.new(
          text: fp_t("date.pick_in_calendar"),
          style: :ghost,
          size: :sm,
          type: "button",
          class: "w-full justify-start",
          data: {"flat-pack-date-picker-command": "show-calendar"}
        ))
      end

      def render_picker_calendar
        content_tag(:div, **calendar_attributes) do
          parts = []
          parts << render_back_to_ranges if @range
          parts << render_month_nav
          parts << render_weekday_row
          parts << render_calendar_grid
          parts << render_summary
          parts << render_inline_actions unless @range
          safe_join(parts)
        end
      end

      def calendar_attributes
        attrs = {class: picker_calendar_section_classes}
        attrs[:data] = {"flat-pack--flatpack-date-picker-target": "calendarView"} if @range
        attrs
      end

      def render_back_to_ranges
        content_tag(:div, class: "mb-3 md:hidden") do
          render(FlatPack::Button::Component.new(
            text: fp_t("date.back_to_range"),
            style: :ghost,
            size: :sm,
            type: "button",
            class: "w-full justify-start",
            data: {"flat-pack-date-picker-command": "show-ranges"}
          ))
        end
      end

      def render_month_nav
        content_tag(:div, class: "flex items-center justify-between gap-2") do
          safe_join([
            render(FlatPack::Button::Component.new(
              text: fp_t("date.previous"),
              style: :ghost,
              size: :sm,
              type: "button",
              data: {"flat-pack-date-picker-command": "previous-month"}
            )),
            content_tag(:p, "", class: "text-sm font-semibold text-[var(--surface-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "monthLabel"}),
            render(FlatPack::Button::Component.new(
              text: fp_t("date.next"),
              style: :ghost,
              size: :sm,
              type: "button",
              data: {"flat-pack-date-picker-command": "next-month"}
            ))
          ])
        end
      end

      def render_weekday_row
        content_tag(:div, class: "mt-3 grid grid-cols-7 gap-1 text-center text-xs font-medium text-[var(--surface-muted-content-color)]") do
          safe_join(weekday_labels.map { |day| content_tag(:span, day) })
        end
      end

      def render_calendar_grid
        content_tag(:div, "", class: "mt-2 grid grid-cols-7 justify-items-center gap-x-0 gap-y-1", data: {"flat-pack--flatpack-date-picker-target": "calendarGrid"})
      end

      def render_summary
        content_tag(:p, "", class: "mt-3 text-xs text-[var(--surface-muted-content-color)]", data: {"flat-pack--flatpack-date-picker-target": "summary"})
      end

      def render_inline_actions
        content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
          safe_join(cancel_and_apply_buttons)
        end
      end

      def render_picker_actions
        content_tag(:div, class: picker_actions_section_classes) do
          safe_join(cancel_and_apply_buttons)
        end
      end

      def cancel_and_apply_buttons
        [
          render(FlatPack::Button::Component.new(
            text: fp_t("date.cancel"),
            style: :ghost,
            size: :sm,
            type: "button",
            data: {"flat-pack-date-picker-command": "cancel"}
          )),
          render(FlatPack::Button::Component.new(
            text: fp_t("date.apply"),
            style: :primary,
            size: :sm,
            type: "button",
            data: {
              "flat-pack-date-picker-command": "apply",
              action: "click->flat-pack--flatpack-date-picker#requestApply"
            }
          ))
        ]
      end

      def picker_panel_attributes
        if @range
          {
            id: @panel_id,
            class: picker_panel_classes,
            style: "display: none;",
            role: "dialog",
            tabindex: "-1",
            aria: {hidden: "true"},
            data: {"flat-pack--flatpack-date-picker-target": "panel"}
          }
        else
          {
            id: @panel_id,
            class: picker_panel_classes,
            role: "dialog",
            tabindex: "-1",
            aria: {hidden: "true"},
            data: {"flat-pack--flatpack-date-picker-target": "panel"}
          }
        end
      end

      def picker_panel_classes
        if @range
          classes(
            "flat-pack-date-picker-panel",
            "hidden",
            "fixed",
            "z-50",
            "inset-0",
            "h-dvh",
            "w-screen",
            "max-w-none",
            "overflow-y-auto",
            "bg-[var(--surface-background-color)]",
            "md:w-auto",
            "md:h-auto",
            "md:inset-auto",
            "md:max-w-none",
            "md:overflow-hidden",
            "md:rounded-[var(--radius-lg)]",
            "md:border",
            "md:border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "shadow-xl",
            "flex",
            "flex-col",
            "md:flex-row",
            "md:flex-wrap",
            "md:items-stretch"
          )
        else
          classes(
            "flat-pack-date-picker-panel",
            "hidden",
            "fixed",
            "z-50",
            "w-auto",
            "overflow-hidden",
            "rounded-[var(--radius-lg)]",
            "border",
            "border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)]",
            "shadow-xl",
            "md:flex",
            "md:items-stretch"
          )
        end
      end

      def picker_ranges_section_classes
        if @range
          classes(
            "flat-pack-date-picker-list-view",
            "border-b",
            "border-[var(--surface-border-color)]",
            "bg-[var(--surface-subtle-background-color)]",
            "p-3",
            "w-full",
            "overflow-y-auto",
            "md:max-w-[150px]",
            "md:sticky",
            "md:top-0",
            "md:w-64",
            "md:self-start",
            "md:border-b-0",
            "md:border-r"
          )
        else
          classes(
            "border-b",
            "border-[var(--surface-border-color)]",
            "bg-[var(--surface-subtle-background-color)]",
            "p-3",
            "max-w-[150px]",
            "md:sticky",
            "md:top-0",
            "md:w-64",
            "md:self-start",
            "md:border-b-0",
            "md:border-r"
          )
        end
      end

      def picker_calendar_section_classes
        if @range
          classes(
            "flat-pack-date-picker-calendar-view",
            "hidden",
            "md:grid",
            "min-w-0",
            "flex-1",
            "p-3"
          )
        else
          classes(
            "min-w-0",
            "flex-1",
            "max-w-[320px]",
            "p-3"
          )
        end
      end

      def picker_actions_section_classes
        classes(
          "mt-auto",
          "sticky",
          "bottom-0",
          "z-10",
          "flex",
          "items-center",
          "justify-end",
          "gap-2",
          "border-t",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "p-3",
          "md:static",
          "md:w-full",
          "md:basis-full"
        )
      end

      def weekday_labels
        %w[mo tu we th fr sa su].map { |day| fp_t("date.weekday_#{day}") }
      end
    end
  end
end
