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
        merge_attributes(class: "fp-overlay relative inline-flex items-start max-w-full")
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
