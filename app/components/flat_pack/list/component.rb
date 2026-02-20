# frozen_string_literal: true

module FlatPack
  module List
    class Component < FlatPack::BaseComponent
      def initialize(
        ordered: false,
        spacing: :comfortable,
        divider: false,
        **system_arguments
      )
        super(**system_arguments)
        @ordered = ordered
        @spacing = spacing.to_sym
        @divider = divider
      end

      def call
        tag_name = @ordered ? :ol : :ul
        
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from list items captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(tag_name, content.html_safe, **list_attributes)
      end

      private

      def list_attributes
        merge_attributes(
          class: list_classes,
          role: "list"
        )
      end

      def list_classes
        classes(
          (@spacing == :dense) ? "space-y-1" : "space-y-2",
          ("divide-y divide-[var(--color-border)]" if @divider)
        )
      end
    end
  end
end
