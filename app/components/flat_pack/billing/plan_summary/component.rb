# frozen_string_literal: true

module FlatPack
  module Billing
    module PlanSummary
      class Component < FlatPack::BaseComponent
        renders_one :actions
        renders_one :footer

        undef_method :with_actions, :with_actions_content
        undef_method :with_footer, :with_footer_content

        STATUSES = {
          active: {key: "active", style: :success},
          trialing: {key: "trial", style: :info},
          past_due: {key: "past_due", style: :warning},
          canceled: {key: "canceled", style: :default},
          incomplete: {key: "incomplete", style: :warning}
        }.freeze

        def initialize(
          plan_name:,
          price_text: nil,
          status: :active,
          renews_on: nil,
          trial_ends_on: nil,
          ends_on: nil,
          scheduled_change_text: nil,
          badges: [],
          description: nil,
          **system_arguments
        )
          super(**system_arguments)
          @plan_name = plan_name
          @price_text = price_text
          @status = status.to_sym
          @renews_on = renews_on
          @trial_ends_on = trial_ends_on
          @ends_on = normalize_ends_on(ends_on)
          @scheduled_change_text = scheduled_change_text.to_s.strip.presence
          @badges = normalize_badges(badges)
          @description = description

          validate_plan_name!
          validate_status!
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        def footer(*args, **kwargs, &block)
          return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:footer, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full"))) do
            render FlatPack::Card::Component.new(background: :default) do |card|
              card.body do
                safe_join([
                  render_heading_row,
                  render_price,
                  render_description,
                  render_notes,
                  render_actions_row
                ].compact)
              end

              if footer?
                card.footer do
                  footer
                end
              end
            end
          end
        end

        private

        def render_heading_row
          content_tag(:div, class: "flex items-start justify-between gap-3 mb-2") do
            safe_join([
              content_tag(:h3, @plan_name, class: "min-w-0 text-lg font-semibold text-[var(--surface-content-color)]"),
              content_tag(:div, class: "flex max-w-full flex-wrap items-center justify-end gap-2") do
                safe_join(heading_badges.map { |badge| render_badge(badge) })
              end
            ])
          end
        end

        def render_price
          return nil if @price_text.blank?

          content_tag(:p, @price_text, class: "text-2xl font-bold text-[var(--surface-content-color)] mb-2")
        end

        def render_description
          return nil if @description.blank?

          content_tag(:p, @description, class: "text-sm text-[var(--surface-muted-content-color)] mb-2")
        end

        def render_notes
          lines = [timing_text, ends_on_text, @scheduled_change_text].compact_blank
          return nil if lines.empty?

          content_tag(:div, class: "mb-4") do
            safe_join(lines.each_with_index.map { |line, index|
              content_tag(:p, line, class: "text-sm text-[var(--surface-muted-content-color)]#{" mt-1" unless index.zero?}")
            })
          end
        end

        def timing_text
          if @status == :trialing && @trial_ends_on.present?
            @trial_ends_on
          else
            @renews_on
          end
        end

        def ends_on_text
          return nil if @ends_on.nil?

          fp_t("billing.plan_summary.ends_on", date: @ends_on.strftime("%-d %b %Y"))
        end

        def heading_badges
          badges = [status_badge]
          badges << cancel_badge if @ends_on
          badges.concat(@badges)
        end

        def status_badge
          {
            text: fp_t("billing.plan_summary.#{status_config.fetch(:key)}"),
            style: status_config.fetch(:style)
          }
        end

        def cancel_badge
          {
            text: fp_t("billing.plan_summary.cancels_at_period_end"),
            style: :warning
          }
        end

        def render_badge(badge)
          render(FlatPack::Badge::Component.new(text: badge[:text], style: badge[:style], size: :sm))
        end

        def render_actions_row
          return nil unless actions?

          content_tag(:div, actions, class: "flex flex-wrap gap-2 mt-2")
        end

        def status_config
          STATUSES.fetch(@status)
        end

        def validate_plan_name!
          return if @plan_name.present?

          raise ArgumentError, "plan_name is required"
        end

        def validate_status!
          return if STATUSES.key?(@status)

          raise ArgumentError, "Invalid status: #{@status.inspect}. Must be one of: #{STATUSES.keys.join(", ")}"
        end

        def normalize_ends_on(ends_on)
          return nil if ends_on.nil?
          return ends_on.to_date if date_like?(ends_on)

          raise ArgumentError, "ends_on must be a date"
        end

        def date_like?(ends_on)
          return false if ends_on.is_a?(String) || ends_on.is_a?(Numeric)

          ends_on.respond_to?(:to_date) && ends_on.respond_to?(:strftime)
        end

        def normalize_badges(badges)
          list = badges.nil? ? [] : badges
          raise ArgumentError, "badges must be an array" unless list.is_a?(Array)

          list.map { |badge| normalize_badge(badge) }
        end

        def normalize_badge(badge)
          hash = badge.respond_to?(:to_h) ? badge.to_h : nil
          raise ArgumentError, "each badge must be a Hash" unless hash.is_a?(Hash)

          normalized = hash.transform_keys(&:to_sym)
          text = normalized[:text].to_s.strip
          raise ArgumentError, "badge text is required" if text.blank?

          raw_style = normalized[:style]
          style = raw_style.respond_to?(:to_sym) ? raw_style.to_sym : raw_style
          unless FlatPack::Badge::Component::VARIANTS.key?(style)
            allowed = FlatPack::Badge::Component::VARIANTS.keys.join(", ")
            raise ArgumentError, "Invalid badge style: #{style.inspect}. Must be one of: #{allowed}"
          end

          {text: text, style: style}
        end
      end
    end
  end
end
