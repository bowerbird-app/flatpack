# frozen_string_literal: true

module FlatPack
  module Shared
    # Breakpoint maps for Masonry columns and Grid span.
    # base has no Tailwind prefix. sm, md, lg, and xl use that prefix.
    module Breakpoints
      NAMES = %i[base sm md lg xl].freeze
      PREFIXES = {
        base: "",
        sm: "sm:",
        md: "md:",
        lg: "lg:",
        xl: "xl:"
      }.freeze

      module_function

      def utility(breakpoint, class_name)
        "#{PREFIXES.fetch(breakpoint)}#{class_name}"
      end

      def normalize(value)
        if value.is_a?(Hash)
          value.to_h { |breakpoint, entry| [breakpoint.to_sym, yield(entry)] }
        else
          {base: yield(value)}
        end
      rescue ArgumentError, TypeError
        value
      end

      def validate_keys!(keys, label:)
        unknown = Array(keys) - NAMES
        return if unknown.empty?

        raise ArgumentError, "Invalid #{label} breakpoints: #{unknown.join(", ")}. Must be one of: #{NAMES.join(", ")}"
      end
    end
  end
end
