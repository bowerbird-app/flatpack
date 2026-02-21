# frozen_string_literal: true

module FlatPack
  module Timeline
    class Component < FlatPack::BaseComponent
      def initialize(**system_arguments)
        super(**system_arguments)
      end

      def call
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from timeline items captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(:div, content.html_safe, **timeline_attributes)
      end

      private

      def timeline_attributes
        merge_attributes(
          class: timeline_classes,
          role: "list"
        )
      end

      def timeline_classes
        classes("relative space-y-8")
      end
    end
  end
end
