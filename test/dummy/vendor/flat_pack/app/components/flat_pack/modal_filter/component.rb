# frozen_string_literal: true

module FlatPack
  module ModalFilter
    class Component < FlatPack::BaseComponent
      renders_one :filter_body

      undef_method :with_filter_body, :with_filter_body_content

      def filter_body(*args, **kwargs, &block)
        return get_slot(:filter_body) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:filter_body, nil, *args, **kwargs, &block)
      end

      def initialize(
        id:,
        form_url:,
        turbo_frame:,
        form_method: :get,
        active_count: 0,
        trigger_label: "Filter",
        button_size: :sm,
        modal_title: "Filters",
        submit_label: "Apply",
        reset_label: "Reset",
        reset_url: nil,
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
        @button_size = button_size.to_sym
        @modal_title = modal_title
        @submit_label = submit_label
        @reset_label = reset_label
        @reset_url = reset_url
        @mobile_form_class = mobile_form_class

        validate_id!
        validate_labels!
        validate_active_count!
        validate_button_size!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_trigger,
            render_modal
          ])
        end
      end

      private

      def render_trigger
        button_tag(
          type: "button",
          class: trigger_button_classes,
          data: {
            action: "click->flat-pack--modal#open",
            "modal-id": modal_id
          }
        ) do
          trigger_content
        end
      end

      def render_modal
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
                filter_body_markup,
                render_actions
              ])
            end
          end
        end
      end

      def render_actions
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

      def trigger_content
        content = [content_tag(:span, @trigger_label)]
        content << render_count_badge if @active_count.positive?
        safe_join(content)
      end

      def render_count_badge
        render FlatPack::Badge::Component.new(
          text: @active_count.to_s,
          style: :primary,
          size: :xs
        )
      end

      def trigger_button_classes
        classes(
          "inline-flex items-center justify-center gap-2",
          "rounded-[var(--button-border-radius)]",
          "font-medium",
          "cursor-pointer",
          "transition-colors duration-base",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]",
          "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)]",
          button_size_classes,
          "bg-[var(--button-secondary-background-color)] hover:bg-[var(--button-secondary-hover-background-color)] text-[var(--button-secondary-text-color)] border border-[var(--button-secondary-border-color)]"
        )
      end

      def button_size_classes
        FlatPack::Button::Component::SIZES.fetch(@button_size)
      end

      def filter_body_markup
        raise ArgumentError, "filter_body slot is required" unless filter_body?

        # Slot content comes from view templates and is expected to be pre-escaped.
        filter_body.to_s.html_safe
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

      def validate_button_size!
        return if FlatPack::Button::Component::SIZES.key?(@button_size)

        raise ArgumentError, "button_size must be one of: #{FlatPack::Button::Component::SIZES.keys.join(", ")}"
      end
    end
  end
end
