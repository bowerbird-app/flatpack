# frozen_string_literal: true

module FlatPack
  module Lightbox
    # A button that opens a lightbox group on one item. Use trigger data on an
    # existing button instead of wrapping it.
    class Trigger < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "block" "w-full" "cursor-pointer" "border-0" "bg-transparent" "p-0" "text-start"
      # "focus-visible:outline-none" "focus-visible:ring-2" "focus-visible:ring-ring" "focus-visible:ring-offset-2"

      def initialize(group:, index: 0, **system_arguments)
        if system_arguments.key?(:class) || system_arguments.key?(:style)
          raise ArgumentError, "Lightbox trigger does not take class or style"
        end

        super(**system_arguments)
        @group = FlatPack::Lightbox::Component.validate_group!(group)
        @index = FlatPack::Lightbox::Component.normalize_index!(index)
      end

      def call
        content_tag(:button, content, type: "button", **trigger_attributes)
      end

      private

      def trigger_attributes
        merge_attributes(
          class: trigger_classes,
          data: FlatPack::Lightbox.trigger_data(group: @group, index: @index)
        )
      end

      def trigger_classes
        [
          "block w-full cursor-pointer border-0 bg-transparent p-0 text-start",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ].join(" ")
      end
    end
  end
end
