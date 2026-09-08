# frozen_string_literal: true

module FlatPack
  module Stepper
    class Component < FlatPack::BaseComponent
      ORIENTATIONS = %i[horizontal vertical].freeze

      def initialize(steps:, current_step: 1, orientation: :horizontal, **system_arguments)
        super(**system_arguments)
        @steps = Array(steps).map { |step| normalize_step(step) }
        @current_step = current_step.to_i
        @orientation = orientation.to_sym
        validate_steps!
        validate_current_step!
        validate_orientation!
      end

      def call
        content_tag(:ol, **list_attributes) do
          safe_join(@steps.each_with_index.map { |step, index| render_step(step, index) })
        end
      end

      private

      def normalize_step(step)
        if step.is_a?(Hash)
          {label: step[:label].to_s, description: step[:description].to_s.presence, href: step[:href]}
        else
          {label: step.to_s, description: nil, href: nil}
        end
      end

      def list_attributes
        merge_attributes(
          class: list_classes,
          aria: {label: "Progress"}
        )
      end

      def list_classes
        classes(
          (@orientation == :vertical) ? "flex flex-col gap-0" : "flex flex-col gap-4 sm:flex-row sm:items-start"
        )
      end

      def render_step(step, index)
        number = index + 1
        status = status_for(number)
        content_tag(:li, class: item_classes, data: {status: status}) do
          safe_join([
            render_marker(number, status),
            render_copy(step, status),
            render_connector(index)
          ].compact)
        end
      end

      def item_classes
        if @orientation == :vertical
          "relative flex gap-3 pb-6 last:pb-0"
        else
          "relative flex flex-1 items-start gap-3"
        end
      end

      def status_for(number)
        if number < @current_step
          :complete
        elsif number == @current_step
          :current
        else
          :upcoming
        end
      end

      def render_marker(number, status)
        content_tag(:span, class: marker_classes(status), aria: {hidden: "true"}) do
          if status == :complete
            render FlatPack::Shared::IconComponent.new(name: "check", size: :sm)
          else
            content_tag(:span, number.to_s, class: "fp-tabular-nums text-xs font-semibold")
          end
        end
      end

      def marker_classes(status)
        base = "relative z-10 flex h-8 w-8 shrink-0 items-center justify-center rounded-full border"
        case status
        when :complete
          "#{base} border-[var(--stepper-complete-color)] bg-[var(--stepper-complete-color)] text-[var(--color-success-text)]"
        when :current
          "#{base} border-[var(--stepper-current-color)] bg-[var(--stepper-current-color)] text-[var(--color-primary-text)]"
        else
          "#{base} border-[var(--stepper-upcoming-color)] bg-[var(--surface-background-color)] text-[var(--stepper-muted-color)]"
        end
      end

      def render_copy(step, status)
        current = status == :current
        content_tag(:div, class: "min-w-0 pt-1") do
          safe_join([
            render_label(step, current),
            (content_tag(:p, step[:description], class: "mt-0.5 text-sm text-[var(--stepper-muted-color)] fp-text-pretty") if step[:description])
          ].compact)
        end
      end

      def render_label(step, current)
        classes = [
          "text-sm font-medium",
          current ? "text-[var(--stepper-label-color)]" : "text-[var(--stepper-muted-color)]"
        ].join(" ")
        href = step[:href].present? ? FlatPack::AttributeSanitizer.sanitize_url(step[:href]) : nil
        if href.present?
          content_tag(:a, step[:label], href: href, class: "#{classes} hover:text-[var(--stepper-label-color)]")
        else
          content_tag(:p, step[:label], class: classes, aria: (current ? {current: "step"} : {}))
        end
      end

      def render_connector(index)
        return if index == @steps.length - 1

        if @orientation == :vertical
          content_tag(:span, nil, class: "pointer-events-none absolute left-4 top-8 bottom-0 w-px bg-[var(--stepper-upcoming-color)]", "aria-hidden": "true")
        else
          content_tag(:span, nil, class: "pointer-events-none absolute left-8 right-0 top-4 hidden h-px bg-[var(--stepper-upcoming-color)] sm:block", "aria-hidden": "true")
        end
      end

      def validate_steps!
        return if @steps.length >= 2 && @steps.all? { |step| step[:label].present? }

        raise ArgumentError, "steps must include at least two labels"
      end

      def validate_current_step!
        return if @current_step.between?(1, @steps.length)

        raise ArgumentError, "current_step must be between 1 and #{@steps.length}"
      end

      def validate_orientation!
        return if ORIENTATIONS.include?(@orientation)

        raise ArgumentError, "Invalid orientation: #{@orientation}. Must be one of: #{ORIENTATIONS.join(", ")}"
      end
    end
  end
end
