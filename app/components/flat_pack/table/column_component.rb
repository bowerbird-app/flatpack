# frozen_string_literal: true

module FlatPack
  module Table
    class ColumnComponent < ViewComponent::Base
      def initialize(label:, attribute: nil, formatter: nil, &block)
        @label = label
        @attribute = attribute
        # Support both formatter: proc and block syntax (though block won't work with ViewComponent)
        @formatter = formatter || block
      end

      def render_header
        tag.th(@label, class: header_classes)
      end

      def render_cell(row)
        # Get the content first
        content = if @formatter
          # Call the formatter proc/lambda
          @formatter.call(row)
        elsif @attribute
          row.public_send(@attribute).to_s
        else
          ""
        end
        
        # Build td tag manually
        "<td class=\"#{cell_classes}\">#{ERB::Util.html_escape(content)}</td>".html_safe
      end

      private

      def header_classes
        "px-4 py-3 text-left text-xs font-medium text-[var(--color-muted-foreground)] uppercase tracking-wider"
      end

      def cell_classes
        "px-4 py-3 text-sm text-[var(--color-foreground)]"
      end
    end
  end
end
