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
        hide_labels: false,
        responsive: true,
        responsive_options: {},
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
        @hide_labels = hide_labels
        @responsive = responsive
        @responsive_options = responsive_options || {}

        validate_names!
        validate_status_lists!
        validate_responsive_options!
      end

      def call
        return render_responsive_filter if @responsive

        render_filter_fields(hide_labels: @hide_labels)
      end

      private

      def render_responsive_filter
        render FlatPack::ResponsiveFilters::Component.new(**responsive_component_options) do |filters|
          filters.fields { render_filter_fields(hide_labels: @hide_labels) }
          filters.mobile_fields { render_filter_fields(hide_labels: true, container_class: responsive_mobile_fields_class) }
        end
      end

      def responsive_component_options
        {
          id: responsive_component_id,
          form_url: @responsive_options[:form_url] || default_form_url,
          turbo_frame: @responsive_options[:turbo_frame],
          active_count: @responsive_options[:active_count].to_i,
          trigger_label: @responsive_options[:trigger_label] || "Filter",
          modal_title: @responsive_options[:modal_title] || "Filters",
          submit_label: @responsive_options[:submit_label] || "Apply",
          reset_label: @responsive_options[:reset_label] || "Reset",
          reset_url: @responsive_options[:reset_url],
          auto_submit_desktop: @responsive_options.fetch(:auto_submit_desktop, true),
          auto_submit_delay: @responsive_options.fetch(:auto_submit_delay, 250),
          desktop_form_class: @responsive_options[:desktop_form_class],
          mobile_form_class: @responsive_options[:mobile_form_class]
        }
      end

      def default_form_url
        request = helpers.respond_to?(:request) ? helpers.request : nil
        request&.path.presence || "/"
      end

      def render_filter_fields(hide_labels:, container_class: nil)
        content_tag(:div, **container_attributes(container_class: container_class)) do
          safe_join([
            render_date_range(hide_labels: hide_labels),
            render_status_select(hide_labels: hide_labels)
          ])
        end
      end

      def render_date_range(hide_labels:)
        render FlatPack::DateRangeInput::Component.new(
          start_name: @start_date_name,
          end_name: @end_date_name,
          start_value: @start_date_value,
          end_value: @end_date_value,
          label: (hide_labels ? nil : "Date Range"),
          class: "w-[220px]"
        )
      end

      def render_status_select(hide_labels:)
        return nil if @status_name.nil?

        render FlatPack::Select::Component.new(
          name: @status_name,
          options: @status_lists,
          value: @status,
          placeholder: @status_placeholder,
          label: (hide_labels ? nil : "Status")
        )
      end

      def responsive_component_id
        @responsive_options[:id] || "chart-default-filter"
      end

      def responsive_mobile_fields_class
        @responsive_options[:mobile_fields_class] || "grid gap-3"
      end

      def container_attributes(container_class: nil)
        class_tokens = [
          @system_arguments[:class],
          "flex flex-wrap items-end gap-3",
          container_class
        ].compact.join(" ")

        {
          class: TailwindMerge::Merger.new.merge(class_tokens),
          data: data_attributes,
          aria: aria_attributes
        }.merge(html_attributes).compact
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

      def validate_responsive_options!
        return unless @responsive

        unless @responsive_options.is_a?(Hash)
          raise ArgumentError, "responsive_options must be a Hash"
        end
      end

      def validate_field_name!(value, field_name)
        return if value.present?

        raise ArgumentError, "#{field_name} is required"
      end
    end
  end
end
