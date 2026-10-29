# frozen_string_literal: true

module FlatPack
  module Overlay
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-overlay" "relative" "inline-flex" "items-start" "max-w-full" "contents"

      renders_one :media
      renders_many :items, "FlatPack::Overlay::Item"

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_media,
            render_items
          ].compact)
        end
      end

      private

      def root_attributes
        attributes = merge_attributes(class: "fp-overlay relative inline-flex items-start max-w-full")
        attributes[:class] = without_forced_light_text(attributes[:class])
        attributes
      end

      # A light glyph on a light secondary button disappears. Hosts that pass
      # text-white onto the overlay wrapper do not get that class.
      def without_forced_light_text(class_name)
        class_name.to_s.split.reject { |token| token.delete_prefix("!") == "text-white" }.join(" ")
      end

      def render_media
        return unless media?

        content_tag(:div, media, class: "contents")
      end

      def render_items
        return unless items?

        safe_join(items)
      end
    end
  end
end
