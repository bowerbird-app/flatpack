# frozen_string_literal: true

module FlatPack
  module Button
    module Dropdown
      # Hidden node inside the dropdown root. A host replaces it with
      # turbo_stream.replace. The controller restyles the trigger in place.
      class TriggerState < FlatPack::BaseComponent
        def initialize(id:, style:, label:, press: nil)
          super()
          @id = id.to_s
          @label = label
          validate_parts!
          @style_name = normalize_style!(style)
          @press_name = resolve_press!(press)
        end

        def call
          tag.span(
            "",
            id: @id,
            hidden: true,
            data: {
              flat_pack__button_dropdown_target: "triggerState",
              style: @style_name,
              press: @press_name,
              label: @label
            }
          )
        end

        private

        def normalize_style!(style)
          raise ArgumentError, "style is required" if style.nil? || style == ""

          name = style.to_sym
          return name if StyleRegistry.known?(name)

          raise ArgumentError, StyleRegistry.invalid_style_message(name)
        end

        def resolve_press!(press)
          return StyleRegistry.press_for(@style_name) if press.nil?

          name = press.to_sym
          return name if StyleRegistry::PRESS_VALUES.include?(name)

          raise ArgumentError, "Invalid press: #{press}. Must be one of: #{StyleRegistry::PRESS_VALUES.join(", ")}"
        end

        def validate_parts!
          raise ArgumentError, "id is required" if @id.blank? || @id.match?(/\s/)
          raise ArgumentError, "label must be a String" unless @label.is_a?(String)
          raise ArgumentError, "label is required" if @label.blank?
        end
      end
    end
  end
end
