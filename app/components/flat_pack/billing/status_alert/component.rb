# frozen_string_literal: true

module FlatPack
  module Billing
    module StatusAlert
      class Component < FlatPack::BaseComponent
        renders_one :actions

        undef_method :with_actions, :with_actions_content

        STATUSES = {
          past_due: {
            style: :warning,
            title: "Past due",
            description: "Update your payment method to keep this workspace on its plan."
          },
          trial_ending: {
            style: :info,
            title: "Trial ending soon",
            description: "Add a payment method before the trial ends to avoid interruption."
          },
          payment_failed: {
            style: :danger,
            title: "Payment failed",
            description: "Your last payment did not go through. Try another card or contact your bank."
          },
          canceled: {
            style: :info,
            title: "Plan canceled",
            description: "This workspace is no longer on a paid plan."
          }
        }.freeze

        ALERT_STYLES = %i[info success warning danger].freeze

        def initialize(
          status: nil,
          style: nil,
          title: nil,
          description: nil,
          dismissible: false,
          **system_arguments
        )
          super(**system_arguments)
          @status = status&.to_sym
          @style = style&.to_sym
          @title = title
          @description = description
          @dismissible = dismissible

          validate_status!
          validate_style!
          validate_content!
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **merge_attributes(class: classes("w-full space-y-3"))) do
            safe_join([
              render_alert,
              render_actions_row
            ].compact)
          end
        end

        private

        def render_alert
          render FlatPack::Alert::Component.new(
            title: resolved_title,
            description: resolved_description,
            style: resolved_style,
            dismissible: @dismissible
          )
        end

        def render_actions_row
          return nil unless actions?

          content_tag(:div, actions, class: "flex flex-wrap gap-2")
        end

        def resolved_title
          @title.presence || status_defaults&.dig(:title)
        end

        def resolved_description
          @description.presence || status_defaults&.dig(:description)
        end

        def resolved_style
          @style || status_defaults&.dig(:style) || :info
        end

        def status_defaults
          return nil if @status.nil?

          STATUSES.fetch(@status)
        end

        def validate_status!
          return if @status.nil?
          return if STATUSES.key?(@status)

          raise ArgumentError, "Invalid status: #{@status.inspect}. Must be one of: #{STATUSES.keys.join(", ")}"
        end

        def validate_style!
          return if @style.nil?
          return if ALERT_STYLES.include?(@style)

          raise ArgumentError, "Invalid style: #{@style.inspect}. Must be one of: #{ALERT_STYLES.join(", ")}"
        end

        def validate_content!
          return if resolved_title.present? || resolved_description.present?

          raise ArgumentError, "title or description is required when status is omitted"
        end
      end
    end
  end
end
