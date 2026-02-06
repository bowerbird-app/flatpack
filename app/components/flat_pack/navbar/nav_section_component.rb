# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavSectionComponent < FlatPack::BaseComponent
      renders_many :items, FlatPack::Navbar::NavItemComponent

      def initialize(title: nil, **system_arguments)
        super(**system_arguments)
        @title = title
      end

      def call
        tag.div(**section_attributes) do
          safe_join([
            render_title,
            render_items
          ].compact)
        end
      end

      private

      def section_attributes
        merge_attributes(
          class: "px-2 mb-6"
        )
      end

      def render_title
        return unless @title

        tag.h3(
          class: [
            "px-3 mb-2 text-xs font-semibold",
            "text-[var(--color-muted-foreground)] uppercase tracking-wider"
          ],
          data: { flat_pack__navbar_target: "sectionTitle" }
        ) do
          @title
        end
      end

      def render_items
        return unless items.any?

        tag.div(class: "space-y-1") do
          safe_join(items)
        end
      end
    end
  end
end
