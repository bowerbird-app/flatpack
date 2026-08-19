# frozen_string_literal: true

module FlatPack
  module Billing
    module UsageMeter
      class Component < FlatPack::BaseComponent
        def initialize(
          label:,
          used:,
          limit: nil,
          unit: nil,
          description: nil,
          tooltip_text: nil,
          **system_arguments
        )
          super(**system_arguments)
          @label = label
          @used = used
          @limit = limit
          @unit = unit
          @description = description
          @tooltip_text = tooltip_text

          validate_label!
          validate_used!
          validate_limit!
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full space-y-2"))) do
            safe_join([
              render_label_row,
              render_helper_text,
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
          used_text = [@used, @unit].compact.join(" ")
          if @limit.nil?
            "#{used_text} · Unlimited"
          else
            limit_text = [@limit, @unit].compact.join(" ")
            "#{@used} of #{limit_text}"
          end
        end

        def render_progress
          return nil if @limit.nil?

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
          ratio = (@limit.to_f.positive? ? (@used.to_f / @limit.to_f) : 0)
          return :danger if ratio >= 1.0
          return :warning if ratio >= 0.8

          :default
        end

        def render_description
          return nil if @description.blank?

          content_tag(:p, @description, class: "text-sm text-[var(--surface-muted-content-color)]")
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

        def validate_limit!
          return if @limit.nil?
          raise ArgumentError, "limit must be numeric" unless @limit.is_a?(Numeric)
          return if @limit.positive?

          raise ArgumentError, "limit must be greater than zero"
        end
      end
    end
  end
end
