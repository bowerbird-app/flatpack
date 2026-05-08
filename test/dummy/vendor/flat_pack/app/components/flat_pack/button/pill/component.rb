# frozen_string_literal: true

module FlatPack
  module Button
    module Pill
      class Component < FlatPack::BaseComponent
        GROUP_CLASSES = "inline-flex gap-1 [border-radius:var(--tabs-pill-corner-radius)] p-1"
        ITEM_BASE_CLASSES = "inline-flex items-center justify-center border border-transparent px-4 py-2 text-sm font-medium [border-radius:var(--tabs-pill-corner-radius)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]"
        ITEM_ACTIVE_CLASSES = "border-[var(--tabs-pill-active-border-color)] bg-[var(--tabs-pill-active-background-color)] text-[var(--tabs-pill-active-text-color)] shadow-[var(--tabs-pill-active-shadow)]"
        ITEM_INACTIVE_CLASSES = "text-[var(--tabs-pill-inactive-text-color)] hover:text-[var(--tabs-pill-inactive-hover-text-color)] hover:bg-[var(--tabs-pill-inactive-hover-background-color)]"

        def initialize(items:, **system_arguments)
          super(**system_arguments)
          @items = normalize_items(items)
        end

        def call
          content_tag(:div, **group_attributes) do
            safe_join(@items.map { |item| render_item(item) })
          end
        end

        private

        def group_attributes
          merge_attributes(class: GROUP_CLASSES)
        end

        def render_item(item)
          link_to item.fetch(:href), **item_attributes(item) do
            item.fetch(:text)
          end
        end

        def item_attributes(item)
          html_attributes = item.fetch(:html_attributes).dup
          existing_aria = (html_attributes.delete(:aria) || {}).dup
          existing_data = (html_attributes.delete(:data) || {}).dup
          existing_class = html_attributes.delete(:class)

          attrs = html_attributes.merge(
            class: merge_css_classes(
              existing_class,
              ITEM_BASE_CLASSES,
              item[:active] ? ITEM_ACTIVE_CLASSES : ITEM_INACTIVE_CLASSES
            )
          )

          attrs[:aria] = existing_aria.merge(current: "page") if item[:active]
          attrs[:aria] = existing_aria if existing_aria.present? && !item[:active]
          attrs[:data] = existing_data if existing_data.present?
          attrs[:target] = item[:target] if item[:target].present?
          attrs[:rel] = "noopener noreferrer" if item[:target] == "_blank"
          attrs
        end

        def normalize_items(items)
          normalized_items = Array(items).map { |item| normalize_item(item) }
          raise ArgumentError, "items must contain at least one pill" if normalized_items.empty?

          normalized_items
        end

        def normalize_item(item)
          symbolized_item = item.to_h.symbolize_keys
          original_href = symbolized_item[:href]
          text = symbolized_item[:text]

          raise ArgumentError, "Each pill item must have href" if original_href.blank?
          raise ArgumentError, "Each pill item must have text" if text.blank?

          href = FlatPack::AttributeSanitizer.sanitize_url(original_href)
          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed." if href.blank?

          {
            text: text,
            href: href,
            active: !!symbolized_item[:active],
            target: symbolized_item[:target],
            html_attributes: FlatPack::AttributeSanitizer.sanitize_attributes(
              symbolized_item.except(:text, :href, :active, :target)
            )
          }
        end

        def merge_css_classes(*class_values)
          TailwindMerge::Merger.new.merge(class_values.compact.join(" "))
        end
      end
    end
  end
end
