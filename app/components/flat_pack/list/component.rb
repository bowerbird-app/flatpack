# frozen_string_literal: true

module FlatPack
  module List
    class Component < FlatPack::BaseComponent
      def initialize(
        ordered: false,
        spacing: :comfortable,
        divider: false,
        selectable: false,
        **system_arguments
      )
        super(**system_arguments)
        @ordered = ordered
        @spacing = spacing.to_sym
        @divider = divider
        @selectable = selectable
      end

      def call
        tag_name = @ordered ? :ol : :ul

        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from list items captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(tag_name, content.to_s.html_safe, **list_attributes)
      end

      private

      def list_attributes
        attrs = {
          class: list_classes,
          role: "list"
        }

        if @selectable
          attrs[:data] = {
            controller: "flat-pack--list-selectable",
            action: "click->flat-pack--list-selectable#activate",
            flat_pack__list_selectable_active_class_value: "bg-[var(--list-item-active-background-color)]"
          }
        end

        merge_attributes(**attrs)
      end

      def list_classes
        classes(
          (@spacing == :dense) ? "space-y-1" : "space-y-3",
          ("divide-y divide-[var(--surface-border-color)]" if @divider)
        )
      end
    end
  end
end
