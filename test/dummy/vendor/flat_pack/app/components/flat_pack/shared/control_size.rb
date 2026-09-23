# frozen_string_literal: true

module FlatPack
  module Shared
    # Shared sm/md/lg box sizes for Checkbox and RadioGroup.
    # md matches today's Checkbox theme token (--checkbox-size 1.25rem).
    # Radio previously used hardcoded h-4 w-4 (1rem); md is a visual grow.
    module ControlSize
      SIZES = {
        sm: "1rem",
        md: "1.25rem",
        lg: "1.5rem"
      }.freeze

      CSS_VAR = "--checkbox-size"

      module_function

      def normalize!(size)
        size.to_sym.tap do |normalized|
          next if SIZES.key?(normalized)

          raise ArgumentError, "Invalid size: #{normalized}. Must be one of: #{SIZES.keys.join(", ")}"
        end
      end

      def css_var_declaration(size)
        "#{CSS_VAR}: #{SIZES.fetch(size)}"
      end
    end
  end
end
