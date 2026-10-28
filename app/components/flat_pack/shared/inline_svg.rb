# frozen_string_literal: true

module FlatPack
  module Shared
    # Trusted inline SVG passed as `icon:`. Same check List::Item and Button use.
    # The string is painted with html_safe. Do not pass user input.
    module InlineSvg
      module_function

      def markup?(value)
        value.is_a?(String) && value.lstrip.start_with?("<svg")
      end
    end
  end
end
