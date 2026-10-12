# frozen_string_literal: true

module FlatPack
  module Button
    module Pill
      class Component < FlatPack::BaseComponent
        SIZES = FlatPack::Shared::PadTextSizes::SIZES

        GROUP_CLASSES = "inline-flex gap-1 [border-radius:var(--tabs-pill-corner-radius)] p-1"
        STYLES = FlatPack::Button::StyleRegistry::BUILT_IN
        ITEM_BASE_CLASSES = "inline-flex items-center justify-center border border-transparent font-medium fp-touch-manipulation [border-radius:var(--tabs-pill-corner-radius)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]"
        ITEM_ACTIVE_CLASSES = FlatPack::Button::PillStyle::ACTIVE_CLASSES
        ITEM_INACTIVE_CLASSES = FlatPack::Button::PillStyle::INACTIVE_CLASSES

        def initialize(items:, size: :md, style: FlatPack::Button::PillStyle::DEFAULT, indicator: nil, **system_arguments)
          super(**system_arguments)
          @pill_style = FlatPack::Button::PillStyle.resolve(style)
          @size = FlatPack::Shared::PadTextSizes.normalize!(size)
          @indicator = FlatPack::Shared::SlideIndicator.normalize(indicator)
          @items = normalize_items(items)
        end

        def call
          content_tag(:div, **group_attributes) do
            nodes = []
            nodes << render_slide_indicator if sliding_indicator?
            nodes.concat(@items.map { |item| render_item(item) })
            safe_join(nodes)
          end
        end

        private

        def group_attributes
          unless sliding_indicator?
            return merge_attributes(
              class: "#{GROUP_CLASSES} #{@pill_style.group_class}",
              data: {fp_style: @pill_style.name.to_s}
            )
          end

          slide_data = merge_data_attributes(
            {fp_style: @pill_style.name.to_s},
            FlatPack::Shared::SlideIndicator.list_data(kind: FlatPack::Shared::SlideIndicator::KIND_PILL)
          )

          {
            class: classes("#{GROUP_CLASSES} #{@pill_style.group_class} #{FlatPack::Shared::SlideIndicator::LIST_CLASS}"),
            data: merge_data_attributes(data_attributes, slide_data),
            aria: aria_attributes
          }.merge(html_attributes).compact
        end

        def render_slide_indicator
          content_tag(
            :span,
            "",
            class: FlatPack::Shared::SlideIndicator.indicator_classes(kind: FlatPack::Shared::SlideIndicator::KIND_PILL),
            aria: {hidden: true},
            data: {"flat-pack--slide-indicator-target": "indicator"}
          )
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
              FlatPack::Shared::PadTextSizes.classes_for(@size),
              (FlatPack::Shared::SlideIndicator::ITEM_CLASS if sliding_indicator?),
              item[:active] ? item_active_classes : item_inactive_classes
            )
          )

          attrs[:aria] = existing_aria.merge(current: "page") if item[:active]
          attrs[:aria] = existing_aria if existing_aria.present? && !item[:active]
          item_data = sliding_indicator? ? merge_data_attributes(existing_data, slide_item_data) : existing_data
          attrs[:data] = item_data if item_data.present?
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

        def item_active_classes
          return FlatPack::Button::PillStyle::ACTIVE_TEXT_CLASSES if sliding_indicator?

          ITEM_ACTIVE_CLASSES
        end

        def item_inactive_classes
          return FlatPack::Button::PillStyle::INACTIVE_TEXT_CLASSES if sliding_indicator?

          ITEM_INACTIVE_CLASSES
        end

        def slide_item_data
          FlatPack::Shared::SlideIndicator.item_data.merge(
            "flat-pack-slide-indicator-active-classes": FlatPack::Button::PillStyle::ACTIVE_TEXT_CLASSES,
            "flat-pack-slide-indicator-inactive-classes": FlatPack::Button::PillStyle::INACTIVE_TEXT_CLASSES
          )
        end

        def sliding_indicator?
          @indicator == :slide
        end

        def merge_css_classes(*class_values)
          TailwindMerge::Merger.new.merge(class_values.compact.join(" "))
        end
      end
    end
  end
end
