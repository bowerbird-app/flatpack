# frozen_string_literal: true

module FlatPack
  module Shared
    # Named height tokens for Chat::Layout and Embed.
    # Tailwind CSS scanning requires these classes as string literals.
    # DO NOT REMOVE:
    # "h-full" "min-h-0" "min-h-full"
    # "h-[20rem]" "min-h-[20rem]"
    # "h-[32rem]" "min-h-[32rem]"
    # "h-[min(40rem,calc(100dvh-16rem))]" "min-h-[min(40rem,calc(100dvh-16rem))]"
    # "h-dvh" "min-h-dvh"
    module FrameHeight
      HEIGHT_CLASSES = {
        full: "h-full",
        sm: "h-[20rem]",
        md: "h-[32rem]",
        lg: "h-[min(40rem,calc(100dvh-16rem))]",
        viewport: "h-dvh"
      }.freeze

      MIN_HEIGHT_CLASSES = {
        full: "min-h-full",
        sm: "min-h-[20rem]",
        md: "min-h-[32rem]",
        lg: "min-h-[min(40rem,calc(100dvh-16rem))]",
        viewport: "min-h-dvh"
      }.freeze

      module_function

      def height_class(token)
        HEIGHT_CLASSES.fetch(token)
      end

      def min_height_class(token)
        MIN_HEIGHT_CLASSES.fetch(token)
      end

      def normalize(value, name:, allow_nil: false)
        return if value.nil? && allow_nil
        raise ArgumentError, "#{name} is required." if value.nil?

        token = value.to_sym
        return token if HEIGHT_CLASSES.key?(token)

        raise ArgumentError, "Invalid #{name}: #{value.inspect}. Must be one of: #{HEIGHT_CLASSES.keys.join(", ")}."
      end
    end
  end
end
