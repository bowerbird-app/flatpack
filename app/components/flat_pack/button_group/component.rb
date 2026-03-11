# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(component) { component }

      undef_method :with_button, :with_button_content

      def initialize(**system_arguments)
        super
      end

      def button(*args, &block)
        set_slot(:buttons, nil, *args, &block)
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
          "rounded-md",
          "shadow-sm",
          "[&>*]:rounded-none",
          "[&>*:first-child]:rounded-l-md",
          "[&>*:last-child]:rounded-r-md",
          "[&>*]:border-r-0",
          "[&>*:last-child]:border-r",
          "[&>*]:shadow-none"
        )
      end
    end
  end
end
