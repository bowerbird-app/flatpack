# frozen_string_literal: true

module FlatPack
  module AnimatedCharacter
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # "w-10" "h-10" "w-16" "h-16" "w-24" "h-24" "w-40" "h-40"
      SIZES = {
        sm: "w-10 h-10",
        md: "w-16 h-16",
        lg: "w-24 h-24",
        xl: "w-40 h-40"
      }.freeze

      def initialize(definition:, state: :idle, size: :xl, label: nil, **system_arguments)
        super(**system_arguments)
        @definition = Definition.sanitize(definition)
        @state = state.to_s
        @size = size.to_sym
        @label = label
        validate!
      end

      def call
        tag.svg(**svg_attributes) do
          safe_join(@definition["parts"].map { |part| render_part(part) })
        end
      end

      private

      def validate!
        validate_text_option!(@label, name: :label)
        raise ArgumentError, "definition needs at least one part" if @definition["parts"].empty?
        unless @definition["states"].key?(@state)
          raise ArgumentError, "Unknown state #{@state.inspect}. Must be one of: #{@definition["states"].keys.join(", ")}"
        end
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def svg_attributes
        attrs = {
          class: classes("fp-animated-character", SIZES.fetch(@size)),
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: @definition.fetch("view_box"),
          fill: "none",
          data: motion_data
        }
        if @label.present?
          attrs[:role] = "img"
          attrs[:aria] = {label: @label}
        else
          attrs[:aria] = {hidden: "true"}
        end
        merge_attributes(**attrs)
      end

      def motion_data
        {
          controller: "flat-pack--svg-motion",
          "flat-pack--svg-motion-definition-value": @definition.to_json,
          "flat-pack--svg-motion-state-value": @state,
          "flat-pack--svg-motion-trigger-value": "mount"
        }
      end

      def render_part(part)
        options = {data: {part: part["name"]}}
        options[:opacity] = part["opacity"] if part.key?("opacity")

        tag.g(**options) do
          safe_join([
            *part["shapes"].map { |shape| render_shape(shape) },
            *part["parts"].map { |child| render_part(child) }
          ])
        end
      end

      def render_shape(shape)
        tag.public_send(shape["type"], **shape["attrs"].transform_keys(&:to_sym))
      end
    end
  end
end
