# frozen_string_literal: true

module FlatPack
  module Accordion
    class Component < FlatPack::BaseComponent
      def initialize(
        allow_multiple: false,
        single_open: nil,
        **system_arguments
      )
        super(**system_arguments)
        @allow_multiple = single_open.nil? ? allow_multiple : !single_open
        @items = []
      end

      def item(id:, title:, open: false, &block)
        @items << {
          id: id,
          title: title,
          open: open,
          content: block ? view_context.capture(&block) : ""
        }
      end

      def call
        # Trigger block execution to collect items via item() calls
        content
        
        content_tag(:div, **container_attributes) do
          safe_join(@items.map { |item| render_item(item) })
        end
      end

      private

      def render_item(item)
        content_tag(:div, class: "border-b border-[var(--surface-border-color)] last:border-b-0") do
          safe_join([
            render_item_trigger(item),
            render_item_content(item)
          ])
        end
      end

      def render_item_trigger(item)
        content_tag(:button, **item_trigger_attributes(item)) do
          safe_join([
            content_tag(:span, item[:title], class: "font-medium"),
            render_item_icon
          ])
        end
      end

      def render_item_icon
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-5 h-5 transition-transform duration-200",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor",
          data: {"flat-pack--accordion-target": "icon"}) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M19 9l-7 7-7-7"
          )
        end
      end

      def render_item_content(item)
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from components captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(:div, **item_content_attributes(item)) do
          content_tag(:div, item[:content].html_safe, class: "p-4")
        end
      end

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--accordion",
            "flat-pack--accordion-allow-multiple-value": @allow_multiple
          },
          class: "border border-[var(--surface-border-color)] rounded-md overflow-hidden bg-[var(--surface-bg-color)]"
        )
      end

      def item_trigger_attributes(item)
        {
          type: "button",
          class: trigger_classes,
          aria: {
            expanded: item[:open],
            controls: item_content_id(item[:id])
          },
          data: {
            "flat-pack--accordion-target": "trigger",
            action: "flat-pack--accordion#toggle"
          }
        }
      end

      def trigger_classes
        "w-full flex items-center justify-between p-4 text-left hover:bg-[var(--surface-muted-bg-color)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-inset"
      end

      def item_content_attributes(item)
        {
          id: item_content_id(item[:id]),
          class: "overflow-hidden transition-all duration-300 ease-in-out",
          data: {
            "flat-pack--accordion-target": "content",
            "flat-pack--accordion-open": item[:open]
          },
          hidden: !item[:open]
        }
      end

      def item_content_id(id)
        "#{id}-content"
      end
    end
  end
end
