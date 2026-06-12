# frozen_string_literal: true

module FlatPack
  module ResponsiveFilters
    class Component < FlatPack::BaseComponent
      renders_one :fields
      renders_one :mobile_fields

      undef_method :with_fields, :with_fields_content
      undef_method :with_mobile_fields, :with_mobile_fields_content

      def fields(*args, **kwargs, &block)
        return get_slot(:fields) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:fields, nil, *args, **kwargs, &block)
      end

      def mobile_fields(*args, **kwargs, &block)
        return get_slot(:mobile_fields) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:mobile_fields, nil, *args, **kwargs, &block)
      end

      def initialize(
        id:,
        form_url:,
        turbo_frame:,
        form_method: :get,
        active_count: 0,
        trigger_label: "Filter",
        modal_title: "Filters",
        submit_label: "Apply",
        reset_label: "Reset",
        reset_url: nil,
        auto_submit_desktop: true,
        auto_submit_delay: 250,
        desktop_form_class: nil,
        mobile_form_class: nil,
        **system_arguments
      )
        super(**system_arguments)
        @id = id
        @form_url = form_url
        @turbo_frame = turbo_frame
        @form_method = form_method
        @active_count = active_count.to_i
        @trigger_label = trigger_label
        @modal_title = modal_title
        @submit_label = submit_label
        @reset_label = reset_label
        @reset_url = reset_url
        @auto_submit_desktop = auto_submit_desktop
        @auto_submit_delay = auto_submit_delay
        @desktop_form_class = desktop_form_class
        @mobile_form_class = mobile_form_class

        validate_id!
        validate_labels!
        validate_active_count!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_mobile_trigger,
            render_desktop_form,
            render_mobile_modal
          ])
        end
      end

      private

      def render_mobile_trigger
        content_tag(:div, class: "md:hidden mb-3") do
          render FlatPack::Button::Component.new(
            text: filter_button_text,
            style: :secondary,
            size: :sm,
            data: {
              action: "click->flat-pack--modal#open",
              "modal-id": modal_id
            }
          )
        end
      end

      def render_desktop_form
        content_tag(:div, class: "hidden md:block mb-3") do
          form_with(
            url: @form_url,
            method: @form_method,
            class: @desktop_form_class,
            data: desktop_form_data
          ) do
            fields_markup
          end
        end
      end

      def render_mobile_modal
        render FlatPack::Modal::Component.new(id: modal_id, title: @modal_title, size: :md) do |modal|
          modal.body do
            form_with(
              id: mobile_form_id,
              url: @form_url,
              method: @form_method,
              class: @mobile_form_class,
              data: {
                turbo_frame: @turbo_frame
              }
            ) do
              safe_join([
                mobile_fields_markup,
                render_mobile_actions
              ])
            end
          end
        end
      end

      def render_mobile_actions
        content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
          safe_join([
            render_reset_button,
            render_apply_button
          ].compact)
        end
      end

      def render_reset_button
        return nil if @reset_url.blank?

        render FlatPack::Button::Component.new(
          text: @reset_label,
          style: :ghost,
          size: :sm,
          url: @reset_url,
          data: {
            turbo_frame: @turbo_frame,
            turbo_prefetch: false
          }
        )
      end

      def render_apply_button
        render FlatPack::Button::Component.new(
          text: @submit_label,
          style: :primary,
          size: :sm,
          type: "submit",
          form: mobile_form_id
        )
      end

      def filter_button_text
        return @trigger_label if @active_count.zero?

        "#{@trigger_label} #{@active_count}"
      end

      def desktop_form_data
        data = {
          turbo_frame: @turbo_frame
        }

        return data unless @auto_submit_desktop

        data.merge(
          controller: "flat-pack--auto-submit",
          action: "input->flat-pack--auto-submit#queueSubmit change->flat-pack--auto-submit#queueSubmit",
          flat_pack__auto_submit_delay_value: @auto_submit_delay
        )
      end

      def fields_markup
        if fields?
          # Slot content comes from view templates and is expected to be pre-escaped.
          fields.to_s.html_safe
        else
          content.to_s
        end
      end

      def mobile_fields_markup
        return fields_markup unless mobile_fields?

        # Slot content comes from view templates and is expected to be pre-escaped.
        mobile_fields.to_s.html_safe
      end

      def modal_id
        "#{@id}-modal"
      end

      def mobile_form_id
        "#{@id}-mobile-form"
      end

      def container_attributes
        merge_attributes(class: classes("w-full"))
      end

      def validate_id!
        return if @id.present?

        raise ArgumentError, "id is required"
      end

      def validate_labels!
        raise ArgumentError, "trigger_label is required" if @trigger_label.blank?
        raise ArgumentError, "modal_title is required" if @modal_title.blank?
        raise ArgumentError, "submit_label is required" if @submit_label.blank?
      end

      def validate_active_count!
        return if @active_count >= 0

        raise ArgumentError, "active_count must be greater than or equal to 0"
      end
    end
  end
end
