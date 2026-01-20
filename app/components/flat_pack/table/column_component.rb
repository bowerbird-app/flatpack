# frozen_string_literal: true

module FlatPack
  module Table
    class ColumnComponent < ViewComponent::Base
      def initialize(label:, attribute: nil, &block)
        @label = label
        @attribute = attribute
        @block = block
      end

      def render_header
        tag.th @label, class: header_classes
      end

      def render_cell(row)
        tag.td class: cell_classes do
          if @block
            @block.call(row)
          elsif @attribute
            row.public_send(@attribute)
          else
            ""
          end
        end
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
