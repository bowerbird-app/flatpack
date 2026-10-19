# frozen_string_literal: true

module FlatPack
  module TextInput
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles
      include FlatPack::Clipboard::QuickCopy

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        help_text: nil,
        character_count: false,
        quick_copy: false,
        min_characters: nil,
        max_characters: nil,
        chrome: :field,
        **system_arguments
      )
        assign_control_chrome!(chrome)
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = value
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @character_count = character_count
        @quick_copy = quick_copy
        @min_characters = min_characters
        @max_characters = max_characters

        validate_name!
        validate_character_limits!
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: input_id,
          **wrapper_attributes
        ) do |field|
          field.with_control { render_input }
          field.with_after_help { render_character_count } if @character_count
        end
      end

      private

      def render_input
        field = tag.input(**input_attributes)
        return field unless @quick_copy

        render_quick_copy_field(
          target_id: input_id,
          button_label: fp_t("text.copy_input"),
          disabled: @disabled
        ) { field }
      end

      def render_character_count
        content_tag(
          :p,
          character_count_text,
          id: character_count_id,
          class: character_count_classes,
          data: {flat_pack__text_input_target: "count"}
        )
      end

      def input_attributes
        attrs = {
          type: "text",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          readonly: @quick_copy,
          required: @required,
          class: input_classes,
          data: input_data_attributes
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def wrapper_attributes
        attrs = {class: wrapper_classes}
        return attrs unless behavior_enabled?

        attrs[:data] = {
          controller: "flat-pack--text-input",
          flat_pack__text_input_character_count_enabled_value: @character_count,
          flat_pack__text_input_min_characters_value: @min_characters,
          flat_pack__text_input_max_characters_value: @max_characters
        }.compact
        attrs
      end

      def input_classes
        form_control_classes(
          error: @error,
          custom_class: @custom_class,
          extra: (@quick_copy ? ["pr-10"] : [])
        )
      end

      def character_count_classes
        "mt-1 text-xs text-[var(--surface-muted-content-color)]"
      end

      def input_data_attributes
        return {} unless behavior_enabled?

        data_attributes = {
          flat_pack__text_input_target: "input"
        }
        data_attributes[:action] = input_actions if input_actions
        data_attributes
      end

      def input_actions
        return unless @character_count

        "input->flat-pack--text-input#updateCharacterCount"
      end

      def behavior_enabled?
        @character_count || @quick_copy
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{input_id}_error"
      end

      def character_count_id
        "#{input_id}_character_count"
      end

      def help_text_id
        "#{input_id}_help_text"
      end

      def character_count_text
        count = (@value || "").to_s.length

        if @max_characters
          fp_t("text.characters_with_limit", count: count, limit: @max_characters)
        else
          fp_t("text.characters", count: count)
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_character_limits!
        return unless @character_count

        if @min_characters&.to_i&.negative?
          raise ArgumentError, "min_characters must be 0 or greater"
        end

        if @max_characters&.to_i&.negative?
          raise ArgumentError, "max_characters must be 0 or greater"
        end

        if @min_characters && @max_characters && @min_characters.to_i > @max_characters.to_i
          raise ArgumentError, "min_characters must be less than or equal to max_characters"
        end
      end
    end
  end
end
