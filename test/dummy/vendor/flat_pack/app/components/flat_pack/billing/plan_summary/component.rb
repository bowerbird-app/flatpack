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
          active: {text: "Active", style: :success},
          trialing: {text: "Trial", style: :info},
          past_due: {text: "Past due", style: :warning},
          canceled: {text: "Canceled", style: :default},
          incomplete: {text: "Incomplete", style: :warning}
        }.freeze

        def initialize(
          plan_name:,
          price_text: nil,
          status: :active,
          renews_on: nil,
          trial_ends_on: nil,
          description: nil,
          **system_arguments
        )
          super(**system_arguments)
          @plan_name = plan_name
          @price_text = price_text
          @status = omitted_status?(status) ? nil : status.to_sym
          @renews_on = renews_on
          @trial_ends_on = trial_ends_on
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
            render FlatPack::Card::Component.new(style: :default) do |card|
              card.body do
                safe_join([
                  render_heading_row,
                  render_price,
                  render_description,
                  render_timing,
                  render_actions_row
                ].compact)
              end

              render_card_footer(card)
            end
          end
        end

        private

        def render_heading_row
          heading = content_tag(:h3, @plan_name, class: "text-lg font-semibold text-[var(--surface-content-color)]")
          return content_tag(:div, heading, class: "mb-2") unless show_status_badge?

          content_tag(:div, class: "flex items-start justify-between gap-3 mb-2") do
            safe_join([
              heading,
              render(FlatPack::Badge::Component.new(
                text: status_config.fetch(:text),
                style: status_config.fetch(:style),
                size: :sm
              ))
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

        def render_timing
          timing = timing_text
          return nil if timing.blank?

          content_tag(:p, timing, class: "text-sm text-[var(--surface-muted-content-color)] mb-4")
        end

        def timing_text
          if @status == :trialing && @trial_ends_on.present?
            @trial_ends_on
          else
            @renews_on
          end
        end

        def render_actions_row
          return nil unless actions?

          content_tag(:div, actions, class: "flex flex-wrap gap-2 mt-2")
        end

        # Capture the PlanSummary footer slot before entering Card#footer.
        # Inside that block `footer` resolves to the Card slot, so
        # `card.footer { footer }` would render an empty footer.
        def render_card_footer(card)
          return unless footer?

          footer_content = footer.to_s
          card.footer do
            footer_content.html_safe
          end
        end

        def show_status_badge?
          !@status.nil?
        end

        def omitted_status?(status)
          status.nil? || status == false
        end

        def status_config
          STATUSES.fetch(@status)
        end

        def validate_plan_name!
          return if @plan_name.present?

          raise ArgumentError, "plan_name is required"
        end

        def validate_status!
          return unless show_status_badge?
          return if STATUSES.key?(@status)

          raise ArgumentError, "Invalid status: #{@status.inspect}. Must be one of: #{STATUSES.keys.join(", ")}"
        end
      end
    end
  end
end
