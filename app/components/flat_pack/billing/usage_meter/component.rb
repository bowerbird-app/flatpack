# frozen_string_literal: true

module FlatPack
  module Billing
    module UsageMeter
      class Component < FlatPack::BaseComponent
        def initialize(
          label:,
          used:,
          limit: nil,
          included: nil,
          purchased: nil,
          warning_ratio: 0.8,
          unit: nil,
          description: nil,
          tooltip_text: nil,
          **system_arguments
        )
          super(**system_arguments)
          @label = label
          @used = used
          @limit = limit
          @included = included
          @purchased = purchased
          @warning_ratio = warning_ratio
          @unit = unit
          @description = description
          @tooltip_text = tooltip_text

          validate_label!
          validate_used!
          validate_warning_ratio!
          validate_included_and_purchased!
          validate_limit!
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full space-y-2"))) do
            safe_join([
              render_label_row,
              render_helper_text,
              render_breakdown,
              render_progress,
              render_description
            ].compact)
          end
        end

        private

        def render_label_row
          label_node = content_tag(:span, @label, class: "text-sm font-medium text-[var(--surface-content-color)]")

          if @tooltip_text.present?
            render FlatPack::Tooltip::Component.new(text: @tooltip_text, placement: :top) do
              label_node
            end
          else
            label_node
          end
        end

        def render_helper_text
          content_tag(:p, helper_text, class: "text-sm text-[var(--surface-muted-content-color)]")
        end

        def helper_text
          return fp_t("billing.usage_meter.none") if none_on_plan?

          used_text = [@used, @unit].compact.join(" ")
          if @limit.nil?
            fp_t("billing.usage_meter.unlimited", used: used_text)
          else
            limit_text = [count_text(@limit), @unit].compact.join(" ")
            fp_t("billing.usage_meter.of", used: count_text(@used), limit: limit_text)
          end
        end

        def render_breakdown
          return nil unless show_breakdown?

          content_tag(:p, breakdown_text, class: "text-sm text-[var(--surface-muted-content-color)]")
        end

        def show_breakdown?
          !@included.nil? && !@purchased.nil? && !none_on_plan?
        end

        def breakdown_text
          fp_t(
            "billing.usage_meter.breakdown",
            included: count_text(@included),
            purchased: count_text(@purchased)
          )
        end

        def render_progress
          return nil if @limit.nil? || none_on_plan?

          render FlatPack::Progress::Component.new(
            value: [@used, 0].max,
            max: @limit,
            style: progress_style,
            size: :md,
            label: @label,
            label_visible: false
          )
        end

        def progress_style
          ratio = @used.to_f / @limit.to_f
          return :danger if ratio >= 1.0
          return :warning if ratio >= @warning_ratio

          :default
        end

        def render_description
          return nil if @description.blank?

          content_tag(:p, @description, class: "text-sm text-[var(--surface-muted-content-color)]")
        end

        def none_on_plan?
          !@limit.nil? && @limit.zero?
        end

        def count_text(number)
          whole = number.to_i
          return whole.to_s if number == whole

          number.to_s
        end

        def validate_label!
          return if @label.present?

          raise ArgumentError, "label is required"
        end

        def validate_used!
          raise ArgumentError, "used must be numeric" unless @used.is_a?(Numeric)
          return if @used >= 0

          raise ArgumentError, "used must be non-negative"
        end

        def validate_warning_ratio!
          raise ArgumentError, "warning_ratio must be numeric" unless @warning_ratio.is_a?(Numeric)
          return if (0..1).cover?(@warning_ratio)

          raise ArgumentError, "warning_ratio must be from 0 to 1"
        end

        def validate_included_and_purchased!
          return if @included.nil? && @purchased.nil?

          if @included.nil? || @purchased.nil?
            raise ArgumentError, "included and purchased must both be set"
          end

          validate_allowance_count!(@included, "included")
          validate_allowance_count!(@purchased, "purchased")

          unless @limit.nil?
            raise ArgumentError, "pass limit or included and purchased, not both"
          end

          @limit = @included + @purchased
        end

        def validate_allowance_count!(count, name)
          raise ArgumentError, "#{name} must be numeric" unless count.is_a?(Numeric)
          return if count >= 0

          raise ArgumentError, "#{name} must be non-negative"
        end

        def validate_limit!
          return if @limit.nil?
          raise ArgumentError, "limit must be numeric" unless @limit.is_a?(Numeric)
          return if @limit >= 0

          raise ArgumentError, "limit must be non-negative"
        end
      end
    end
  end
end
