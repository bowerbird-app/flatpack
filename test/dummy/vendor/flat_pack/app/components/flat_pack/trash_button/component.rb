# frozen_string_literal: true

module FlatPack
  module TrashButton
    class Component < FlatPack::BaseComponent
      SIZES = %i[sm md lg].freeze
      EXPANDS = %i[right left].freeze
      METHODS = %i[delete post put patch get].freeze
      DEFAULT_TIMEOUT = 4000

      def initialize(
        text: nil,
        confirm_label: nil,
        url: nil,
        method: :delete,
        expand: :right,
        size: :md,
        timeout: DEFAULT_TIMEOUT,
        armed: false,
        **system_arguments
      )
        super(**system_arguments)
        @text = text.presence
        @confirm_label = confirm_label.presence || fp_t("trash_button.confirm")
        @method = method.to_sym
        @expand = expand.to_sym
        @size = size.to_sym
        @timeout = normalize_timeout(timeout)
        @armed = armed == true

        if url
          @url = FlatPack::AttributeSanitizer.sanitize_url(url)
          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed." if @url.blank?
        else
          @url = nil
        end

        validate_size!
        validate_expand!
        validate_method!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_primary,
            render_cancel_slot,
            render_live_region
          ])
        end
      end

      private

      def render_primary
        content_tag(:div, class: "fp-trash-button__primary", data: {"flat-pack--trash-button-target": "primary"}) do
          safe_join([
            content_tag(:div, **rest_attributes) { render_arm_button },
            content_tag(:div, **armed_attributes) { render_confirm_control }
          ])
        end
      end

      def render_cancel_slot
        content_tag(:div, **cancel_slot_attributes) do
          content_tag(:div, class: "fp-trash-button__cancel-inner") do
            render_cancel_button
          end
        end
      end

      def render_live_region
        content_tag(
          :div,
          "",
          class: "sr-only",
          aria: {live: "polite"},
          data: {"flat-pack--trash-button-target": "live"}
        )
      end

      def render_arm_button
        render FlatPack::Button::Component.new(
          text: arm_text,
          icon: "trash",
          icon_only: icon_only?,
          size: @size,
          style: :default,
          type: "button",
          class: "fp-trash-button__arm",
          data: {
            action: "click->flat-pack--trash-button#arm",
            "flat-pack--trash-button-target": "arm"
          },
          aria: {expanded: @armed ? "true" : "false"}
        )
      end

      def render_confirm_control
        button = render_confirm_button
        return button if @url.blank?

        content_tag(:form, **form_attributes) do
          safe_join([
            method_override_field,
            authenticity_field,
            button
          ].compact)
        end
      end

      def render_confirm_button
        render FlatPack::Button::Component.new(
          text: @confirm_label,
          style: :danger,
          size: @size,
          type: @url.present? ? "submit" : "button",
          class: "fp-trash-button__confirm-btn",
          data: {
            action: "click->flat-pack--trash-button#confirm",
            "flat-pack--trash-button-target": "confirm"
          }
        )
      end

      def render_cancel_button
        render FlatPack::Button::Component.new(
          text: fp_t("common.cancel"),
          icon: "x-mark",
          icon_only: true,
          size: @size,
          style: :default,
          type: "button",
          class: "fp-trash-button__cancel-btn",
          data: {
            action: "click->flat-pack--trash-button#cancel",
            "flat-pack--trash-button-target": "cancel"
          }
        )
      end

      def root_attributes
        attrs = merge_attributes(
          class: "fp-trash-button",
          role: "group",
          data: {
            controller: "flat-pack--trash-button",
            fp_armed: @armed ? "true" : "false",
            fp_expand: @expand.to_s,
            "flat-pack--trash-button-armed-value": @armed,
            "flat-pack--trash-button-timeout-value": @timeout,
            "flat-pack--trash-button-expand-value": @expand.to_s,
            "flat-pack--trash-button-armed-announcement-value": fp_t("trash_button.armed"),
            "flat-pack--trash-button-restored-announcement-value": fp_t("trash_button.restored")
          }
        )
        attrs[:aria] = {label: arm_text}.merge(attrs[:aria] || {})
        attrs
      end

      def rest_attributes
        attrs = {
          class: "fp-trash-button__rest",
          data: {"flat-pack--trash-button-target": "rest"}
        }
        attrs[:inert] = true if @armed
        attrs
      end

      def armed_attributes
        attrs = {
          class: "fp-trash-button__confirm",
          data: {"flat-pack--trash-button-target": "armed"}
        }
        attrs[:inert] = true unless @armed
        attrs
      end

      def cancel_slot_attributes
        attrs = {
          class: "fp-trash-button__cancel-slot",
          data: {"flat-pack--trash-button-target": "cancelSlot"}
        }
        attrs[:inert] = true unless @armed
        attrs
      end

      def form_attributes
        {
          action: @url,
          method: form_http_method,
          accept_charset: "UTF-8",
          class: "contents",
          data: {
            turbo: true,
            "flat-pack--trash-button-target": "form"
          }
        }
      end

      def form_http_method
        (@method == :get) ? "get" : "post"
      end

      def method_override_field
        return if @method == :get || @method == :post

        tag.input(type: "hidden", name: "_method", value: @method, autocomplete: "off")
      end

      def authenticity_field
        return if @method == :get

        token = form_authenticity_token_value
        return if token.blank?

        tag.input(type: "hidden", name: "authenticity_token", value: token, autocomplete: "off")
      end

      def form_authenticity_token_value
        return unless helpers.respond_to?(:form_authenticity_token)

        helpers.form_authenticity_token
      rescue ArgumentError, NoMethodError
        nil
      end

      def icon_only?
        @text.blank?
      end

      def arm_text
        @text.presence || fp_t("trash_button.trash")
      end

      def normalize_timeout(timeout)
        return 0 if timeout == false || timeout.nil?

        value = begin
          Integer(timeout)
        rescue ArgumentError, TypeError
          raise ArgumentError, "timeout must be a non-negative integer, 0, or false"
        end
        raise ArgumentError, "timeout must be a non-negative integer" if value.negative?

        value
      end

      def validate_size!
        return if SIZES.include?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.join(", ")}"
      end

      def validate_expand!
        return if EXPANDS.include?(@expand)

        raise ArgumentError, "Invalid expand: #{@expand}. Must be one of: #{EXPANDS.join(", ")}"
      end

      def validate_method!
        return if METHODS.include?(@method)

        raise ArgumentError, "Invalid method: #{@method}. Must be one of: #{METHODS.join(", ")}"
      end
    end
  end
end
