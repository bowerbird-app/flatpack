# frozen_string_literal: true

module FlatPack
  module SegmentedButtons
    class Component < FlatPack::BaseComponent
      SIZES = FlatPack::Button::Component::SIZES
      STYLES = FlatPack::Button::StyleRegistry::BUILT_IN
      UNSELECTED_STYLE = :secondary

      renders_many :buttons, lambda { |text:, selected: false, size: nil, **args|
        if args.key?(:style)
          raise ArgumentError, "Pass style: to SegmentedButtons, not to a segment."
        end

        style = selected ? @style : UNSELECTED_STYLE
        FlatPack::Button::Component.new(
          text: text,
          style: style,
          size: size.nil? ? @size : size,
          **args
        )
      }

      undef_method :with_button, :with_button_content

      def initialize(size: :md, style: :primary, **system_arguments)
        super(**system_arguments)
        @size = size.to_sym
        @style = style.to_sym
        validate_size!
        validate_style!
      end

      def button(*args, **kwargs, &block)
        set_slot(:buttons, nil, *args, **kwargs, &block)
      end

      def call
        content_tag(:div, **group_attributes) do
          safe_join(buttons.map(&:call))
        end
      end

      private

      def group_attributes
        merge_attributes(
          class: group_classes
        )
      end

      def group_classes
        classes(
          "inline-flex",
          "rounded-[var(--radius-md)]",
          "shadow-sm",
          "[&>*]:rounded-none",
          "[&>*:first-child]:rounded-l-[var(--radius-md)]",
          "[&>*:last-child]:rounded-r-[var(--radius-md)]",
          "[&>*]:border-r-0",
          "[&>*:last-child]:border-r",
          "[&>*]:shadow-none"
        )
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_style!
        return if FlatPack::Button::StyleRegistry.known?(@style)

        raise ArgumentError, FlatPack::Button::StyleRegistry.invalid_style_message(@style)
      end
    end
  end
end
