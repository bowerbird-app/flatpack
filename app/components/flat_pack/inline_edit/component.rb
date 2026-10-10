# frozen_string_literal: true

module FlatPack
  module InlineEdit
    class Component < FlatPack::BaseComponent
      include FlatPack::Shared::ExecCommandBalloon

      MODES = %i[text plain rich].freeze
      TAGS = %i[span h1 h2 h3 h4 h5 h6 p div].freeze
      CUES = %i[underline tint none].freeze
      METHODS = %i[patch put post].freeze
      BLOCK_TAGS = %i[h1 h2 h3 h4 h5 h6 p div].freeze

      def initialize(
        name:,
        value: nil,
        tag: nil,
        mode: :text,
        update_url: nil,
        method: :patch,
        label: FlatPack::Copy::OMITTED,
        placeholder: FlatPack::Copy::OMITTED,
        maxlength: nil,
        required: false,
        save_on_blur: true,
        cue: :underline,
        **system_arguments
      )
        super(**system_arguments)
        @name = name.to_s
        @mode = mode.to_sym
        @cue = cue.to_sym
        @method = method.to_sym
        @required = boolean_flag(required)
        @save_on_blur = boolean_flag(save_on_blur)
        @maxlength = maxlength.present? ? Integer(maxlength) : nil
        @label = fp_text(label, "inline_edit.label")
        @placeholder = fp_text(placeholder, "inline_edit.placeholder")
        @update_url = sanitize_update_url(update_url)
        @wrapped = false
        @tag = resolve_tag(tag)
        @value = initial_value(value)

        validate_name!
        validate_mode!
        validate_tag!
        validate_cue!
        validate_method!
        validate_maxlength!
      end

      def before_render
        @wrapped = content.present?
      end

      def call
        content_tag(wrapper_tag, **wrapper_attributes) do
          safe_join([
            render_surface,
            render_hidden_field,
            render_status,
            render_live_region,
            (rich? ? render_bubble : nil)
          ].compact)
        end
      end

      private

      def wrapper_tag
        (wrapped? || block_tag?) ? :div : :span
      end

      def wrapper_attributes
        attrs = {class: wrapper_classes, data: wrapper_data}
        extras = html_attributes
        extras = extras.except(:class) unless wrapped?
        attrs.merge(extras)
      end

      def wrapper_classes
        [
          "fp-inline-edit",
          block_tag? || wrapped? ? "fp-inline-edit--block" : "fp-inline-edit--inline",
          wrapped? ? "fp-inline-edit--wrapped" : "fp-inline-edit--tag",
          "fp-inline-edit--#{@mode}",
          "fp-inline-edit--cue-#{@cue}"
        ].join(" ")
      end

      def wrapper_data
        data = {
          controller: "flat-pack--inline-edit",
          action: [
            "click->flat-pack--inline-edit#onClick",
            "focusin->flat-pack--inline-edit#onFocusIn",
            "focusout->flat-pack--inline-edit#onFocusOut",
            "keydown->flat-pack--inline-edit#onKeydown"
          ].join(" "),
          flat_pack__inline_edit_name_value: @name,
          flat_pack__inline_edit_mode_value: @mode.to_s,
          flat_pack__inline_edit_method_value: @method.to_s,
          flat_pack__inline_edit_required_value: @required,
          flat_pack__inline_edit_save_on_blur_value: @save_on_blur,
          flat_pack__inline_edit_label_value: @label,
          flat_pack__inline_edit_placeholder_value: @placeholder
        }
        data[:flat_pack__inline_edit_update_url_value] = @update_url if @update_url
        data[:flat_pack__inline_edit_maxlength_value] = @maxlength if @maxlength
        data
      end

      def render_surface
        return content if wrapped?

        content_tag(@tag, surface_html, **surface_attributes)
      end

      def surface_attributes
        attrs = {
          class: surface_classes,
          tabindex: 0,
          role: "textbox",
          spellcheck: @mode == :rich,
          data: {
            flat_pack__inline_edit_target: "surface",
            placeholder: @placeholder
          },
          aria: surface_aria
        }
        attrs
      end

      def surface_classes
        tokens = ["fp-inline-edit__surface"]
        tokens << "is-empty" if value_blank?
        wrapped? ? tokens.join(" ") : classes(*tokens)
      end

      def surface_aria
        aria = {
          label: @label,
          placeholder: @placeholder,
          describedby: live_region_id
        }
        aria[:multiline] = "true" unless @mode == :text
        aria[:required] = "true" if @required
        aria
      end

      def surface_html
        return "".html_safe if @value.blank?
        return @value if rich?

        ERB::Util.html_escape(@value)
      end

      def render_hidden_field
        tag.input(
          type: "hidden",
          name: @name,
          value: hidden_field_value,
          data: {flat_pack__inline_edit_target: "field"}
        )
      end

      def hidden_field_value
        return @value.to_s if rich?

        @value.to_s
      end

      def render_status
        content_tag(
          :span,
          class: "fp-inline-edit__status",
          data: {flat_pack__inline_edit_target: "status"},
          aria: {hidden: true}
        ) do
          safe_join([
            content_tag(:span, class: "fp-inline-edit__spinner", hidden: true, data: {flat_pack__inline_edit_target: "spinner"}) do
              render(FlatPack::Spinner::Component.new(size: :sm, label: nil))
            end,
            content_tag(:span, tick_icon, class: "fp-inline-edit__tick", hidden: true, data: {flat_pack__inline_edit_target: "tick"})
          ])
        end
      end

      def tick_icon
        <<~SVG.html_safe
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" width="14" height="14" aria-hidden="true"><path d="M5 12.5l5 5L19 7"/></svg>
        SVG
      end

      def render_live_region
        content_tag(
          :span,
          "",
          id: live_region_id,
          class: "fp-inline-edit__live",
          role: "status",
          aria: {live: "polite", atomic: "true"},
          data: {flat_pack__inline_edit_target: "live"}
        )
      end

      def render_bubble
        render_exec_command_balloon(
          controller: "flat-pack--inline-edit",
          target: "bubble"
        )
      end

      def live_region_id
        @live_region_id ||= "fp-inline-edit-live-#{object_id}"
      end

      def wrapped?
        @wrapped
      end

      def rich?
        @mode == :rich
      end

      def block_tag?
        BLOCK_TAGS.include?(@tag)
      end

      def value_blank?
        @value.to_s.strip.empty?
      end

      def resolve_tag(tag)
        return :div if tag.nil? && @mode != :text
        return :span if tag.nil?

        tag.to_sym
      end

      def initial_value(value)
        return "" if value.nil?
        return FlatPack::RichTextSanitizer.sanitize(value.to_s) if rich?

        value.to_s
      end

      def sanitize_update_url(url)
        return nil if url.nil? || url.to_s.strip.empty?

        sanitized = FlatPack::AttributeSanitizer.sanitize_url(url)
        if sanitized.nil?
          raise ArgumentError, "update_url is not a safe URL"
        end

        sanitized
      end

      def boolean_flag(value)
        ![false, 0, "0", "false"].include?(value)
      end

      def validate_name!
        return if @name.present?

        raise ArgumentError, "name is required"
      end

      def validate_mode!
        return if MODES.include?(@mode)

        raise ArgumentError, "Invalid mode: #{@mode}. Must be one of: #{MODES.join(", ")}"
      end

      def validate_tag!
        return if TAGS.include?(@tag)

        raise ArgumentError, "Invalid tag: #{@tag}. Must be one of: #{TAGS.join(", ")}"
      end

      def validate_cue!
        return if CUES.include?(@cue)

        raise ArgumentError, "Invalid cue: #{@cue}. Must be one of: #{CUES.join(", ")}"
      end

      def validate_method!
        return if METHODS.include?(@method)

        raise ArgumentError, "Invalid method: #{@method}. Must be one of: #{METHODS.join(", ")}"
      end

      def validate_maxlength!
        return if @maxlength.nil? || @maxlength.positive?

        raise ArgumentError, "maxlength must be a positive integer"
      end
    end
  end
end
