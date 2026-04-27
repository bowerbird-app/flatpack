# frozen_string_literal: true

module FlatPack
  module Link
    class Component < FlatPack::BaseComponent
      attr_reader :href, :method, :target

      def initialize(
        href:,
        method: nil,
        target: nil,
        **system_arguments
      )
        # Validate href for security before passing to parent
        @href = FlatPack::AttributeSanitizer.validate_href!(href)
        @method = method
        @target = target

        super(**system_arguments)
      end

      def call
        link_to @href, **link_attributes do
          content
        end
      end

      private

      def link_attributes
        attrs = {
          class: link_classes,
          method: @method,
          target: @target
        }
        # Add rel="noopener noreferrer" for security when opening in new tab
        attrs[:rel] = "noopener noreferrer" if @target == "_blank"
        merge_attributes(**attrs).compact
      end

      def link_classes
        classes("flat-pack-link")
      end
    end
  end
end
