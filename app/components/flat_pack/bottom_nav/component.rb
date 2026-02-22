# frozen_string_literal: true

module FlatPack
  module BottomNav
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fixed" "inset-x-0" "bottom-0" "border-t" "bg-[var(--surface-bg-color)]"
      # "grid" "grid-cols-4" "w-full"

      renders_many :items, "FlatPack::BottomNav::Item::Component"

      def item(**args, &block)
        with_item(**args, &block)
      end

      def call
        content_tag(:nav, **container_attributes) do
          content_tag(:div, class: inner_classes) do
            safe_join(items)
          end
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes,
          aria: resolved_aria_attributes
        )
      end

      def resolved_aria_attributes
        {label: "Bottom navigation"}.merge(aria_attributes)
      end

      def container_classes
        classes(
          "fixed",
          "inset-x-0",
          "bottom-0",
          "w-full",
          "z-40",
          "border-t",
          "border-[var(--surface-border-color)]",
          "bg-[var(--surface-bg-color)]",
          "pb-[env(safe-area-inset-bottom)]"
        )
      end

      def inner_classes
        "grid w-full grid-cols-4"
      end
    end
  end
end
