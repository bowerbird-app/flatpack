# frozen_string_literal: true

module FlatPack
  module Shared
    # Shared sm/md/lg padding + text for Button::Pill and Tabs.
    # md matches the previous hard-coded px-4 py-2 text-sm (same as Button md tokens).
    module PadTextSizes
      SIZES = FlatPack::Button::Component::SIZES

      module_function

      def normalize!(size)
        size.to_sym.tap do |normalized|
          next if SIZES.key?(normalized)

          raise ArgumentError, "Invalid size: #{normalized}. Must be one of: #{SIZES.keys.join(", ")}"
        end
      end

      def classes_for(size)
        SIZES.fetch(size)
      end
    end
  end
end
