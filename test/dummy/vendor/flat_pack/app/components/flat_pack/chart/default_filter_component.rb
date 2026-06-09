# frozen_string_literal: true

module FlatPack
  module Chart
    class DefaultFilterComponent < FlatPack::BaseComponent
      def initialize(
        status_lists:, start_date_name: "start_date",
        end_date_name: "end_date",
        start_date_value: nil,
        end_date_value: nil,
        status_name: "status",
        status: nil,
        status_placeholder: "All",
        **system_arguments
      )
        super(**system_arguments)
        @start_date_name = start_date_name
        @end_date_name = end_date_name
        @start_date_value = start_date_value
        @end_date_value = end_date_value
        @status_name = status_name
        @status = status
        @status_lists = status_lists
        @status_placeholder = status_placeholder

        validate_names!
        validate_status_lists!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_date_range,
            render_status_select
          ])
        end
      end

      private

      def render_date_range
        render FlatPack::DateRangeInput::Component.new(
          start_name: @start_date_name,
          end_name: @end_date_name,
          start_value: @start_date_value,
          end_value: @end_date_value,
          label: "Date Range",
          class: "w-[220px]"
        )
      end

      def render_status_select
        return nil if @status_name.nil?

        render FlatPack::Select::Component.new(
          name: @status_name,
          options: @status_lists,
          value: @status,
          placeholder: @status_placeholder,
          label: "Status"
        )
      end

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes("flex flex-wrap items-end gap-3")
      end

      def validate_names!
        validate_field_name!(@start_date_name, "start_date_name")
        validate_field_name!(@end_date_name, "end_date_name")
        validate_field_name!(@status_name, "status_name") unless @status_name.nil?
      end

      def validate_status_lists!
        return if @status_lists.is_a?(Array) || @status_lists.is_a?(Hash)

        raise ArgumentError, "status_lists must be an Array or Hash"
      end

      def validate_field_name!(value, field_name)
        return if value.present?

        raise ArgumentError, "#{field_name} is required"
      end
    end
  end
end
