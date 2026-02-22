# frozen_string_literal: true

module FlatPack
  module TextArea
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-warning" "border-warning"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        rows: 3,
        character_count: false,
        min_characters: nil,
        max_characters: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = value
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @rows = rows
        @character_count = character_count
        @min_characters = min_characters
        @max_characters = max_characters

        validate_name!
        validate_rows!
        validate_character_limits!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_label,
            render_textarea,
            render_character_count,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(textarea_id, @label, class: label_classes)
      end

      def render_textarea
        content_tag(:textarea, @value, **textarea_attributes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def render_character_count
        return unless @character_count

        content_tag(
          :p,
          character_count_text,
          id: character_count_id,
          class: character_count_classes,
          data: {flat_pack__text_area_target: "count"}
        )
      end

      def textarea_attributes
        attrs = {
          name: @name,
          id: textarea_id,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          rows: @rows,
          class: textarea_classes,
          data: {
            flat_pack__text_area_target: "textarea",
            action: "input->flat-pack--text-area#autoExpand input->flat-pack--text-area#updateCharacterCount"
          }.compact
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**attrs.compact)
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def wrapper_attributes
        {
          class: wrapper_classes,
          data: {
            controller: "flat-pack--text-area",
            flat_pack__text_area_min_characters_value: @min_characters,
            flat_pack__text_area_max_characters_value: @max_characters,
            flat_pack__text_area_character_count_enabled_value: @character_count
          }.compact
        }
      end

      def label_classes
        classes(
          "block text-sm font-medium text-foreground mb-1.5"
        )
      end

      def textarea_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "rounded-md",
          "border",
          "bg-background",
          "text-foreground",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          "resize-none"
        ]

        base_classes << if @error
          "border-warning"
        else
          "border-border"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-1 text-sm text-warning"
      end

      def character_count_classes
        "mt-1 text-xs text-muted-foreground"
      end

      def textarea_id
        @textarea_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{textarea_id}_error"
      end

      def character_count_id
        "#{textarea_id}_character_count"
      end

      def character_count_text
        count = (@value || "").to_s.length

        if @max_characters
          "#{count}/#{@max_characters} characters"
        else
          "#{count} characters"
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_rows!
        raise ArgumentError, "rows must be a positive integer" if @rows.to_i <= 0
      end

      def validate_character_limits!
        return unless @character_count

        if @min_characters && @min_characters.to_i.negative?
          raise ArgumentError, "min_characters must be 0 or greater"
        end

        if @max_characters && @max_characters.to_i.negative?
          raise ArgumentError, "max_characters must be 0 or greater"
        end

        if @min_characters && @max_characters && @min_characters.to_i > @max_characters.to_i
          raise ArgumentError, "min_characters must be less than or equal to max_characters"
        end
      end
    end
  end
end
