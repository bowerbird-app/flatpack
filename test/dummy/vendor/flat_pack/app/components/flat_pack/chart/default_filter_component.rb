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
        minimized: true,
        minimized_options: {},
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
        @minimized = minimized
        @minimized_options = minimized_options || {}

        validate_names!
        validate_status_lists!
        validate_minimized_options!
      end

      def call
        return render_minimized_filter if @minimized

        render_filter_fields(hide_labels: @hide_labels)
      end

      private

      def render_minimized_filter
        safe_join([
          render_desktop_filter_form,
          render_mobile_filter_form
        ])
      end

      def render_desktop_filter_form
        content_tag(:div, class: "hidden md:block") do
          form_with(
            url: minimized_form_url,
            method: :get,
            class: minimized_desktop_form_class,
            data: desktop_form_data
          ) do
            render_filter_fields(hide_labels: @hide_labels)
          end
        end
      end

      def render_mobile_filter_form
        content_tag(:div, class: "md:hidden") do
          render FlatPack::MinimizedFilters::Component.new(**minimized_component_options) do |filters|
            filters.filter_body do
              render_filter_fields(hide_labels: true, container_class: minimized_mobile_fields_class)
            end
          end
        end
      end

      def minimized_component_options
        {
          id: minimized_component_id,
          form_url: minimized_form_url,
          turbo_frame: minimized_turbo_frame,
          active_count: @minimized_options[:active_count].to_i,
          trigger_label: @minimized_options[:trigger_label] || "Filter",
          modal_title: @minimized_options[:modal_title] || "Filters",
          submit_label: @minimized_options[:submit_label] || "Apply",
          reset_label: @minimized_options[:reset_label] || "Reset",
          reset_url: @minimized_options[:reset_url],
          mobile_form_class: @minimized_options[:mobile_form_class]
        }
      end

      def minimized_form_url
        @minimized_options[:form_url] || default_form_url
      end

      def minimized_turbo_frame
        @minimized_options[:turbo_frame]
      end

      def minimized_desktop_form_class
        @minimized_options[:desktop_form_class]
      end

      def minimized_auto_submit_desktop?
        @minimized_options.fetch(:auto_submit_desktop, true)
      end

      def minimized_auto_submit_delay
        @minimized_options.fetch(:auto_submit_delay, 250)
      end

      def desktop_form_data
        data = {}
        data[:turbo_frame] = minimized_turbo_frame if minimized_turbo_frame.present?

        return data unless minimized_auto_submit_desktop?

        data.merge(
          controller: "flat-pack--auto-submit",
          action: "input->flat-pack--auto-submit#queueSubmit change->flat-pack--auto-submit#queueSubmit",
          flat_pack__auto_submit_delay_value: minimized_auto_submit_delay
        )
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

      def minimized_component_id
        @minimized_options[:id] || "chart-default-filter"
      end

      def minimized_mobile_fields_class
        @minimized_options[:mobile_fields_class] || "grid gap-3"
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

      def validate_minimized_options!
        return unless @minimized

        unless @minimized_options.is_a?(Hash)
          raise ArgumentError, "minimized_options must be a Hash"
        end
      end

      def validate_field_name!(value, field_name)
        return if value.present?

        raise ArgumentError, "#{field_name} is required"
      end
    end
  end
end
