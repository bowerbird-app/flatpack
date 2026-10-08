# frozen_string_literal: true

module FlatPack
  module SegmentedButtons
    class Component < FlatPack::BaseComponent
      SIZES = FlatPack::Button::Component::SIZES

      renders_many :buttons, lambda { |text:, selected: false, size: nil, **args|
        style = selected ? :primary : :secondary
        FlatPack::Button::Component.new(
          text: text,
          style: style,
          size: size.nil? ? @size : size,
          **args
        )
      }

      undef_method :with_button, :with_button_content

      def initialize(size: :md, **system_arguments)
        super(**system_arguments)
        @size = size.to_sym
        validate_size!
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
    end
  end
end
