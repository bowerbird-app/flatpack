# frozen_string_literal: true

module FlatPack
  module Accordion
    class Component < FlatPack::BaseComponent
      # Density for trigger/content padding and title text. md matches current 1rem padding.
      # "text-sm" "text-base" "text-lg"
      # "p-[var(--accordion-trigger-padding-sm)]" "p-[var(--accordion-content-padding-sm)]"
      # "p-[var(--accordion-trigger-padding-md)]" "p-[var(--accordion-content-padding-md)]"
      # "p-[var(--accordion-trigger-padding-lg)]" "p-[var(--accordion-content-padding-lg)]"
      SIZES = {
        sm: {
          trigger_padding: "p-[var(--accordion-trigger-padding-sm)]",
          content_padding: "p-[var(--accordion-content-padding-sm)]",
          title: "text-sm font-medium",
          icon: :sm
        },
        md: {
          trigger_padding: "p-[var(--accordion-trigger-padding-md)]",
          content_padding: "p-[var(--accordion-content-padding-md)]",
          title: "font-medium",
          icon: :md
        },
        lg: {
          trigger_padding: "p-[var(--accordion-trigger-padding-lg)]",
          content_padding: "p-[var(--accordion-content-padding-lg)]",
          title: "text-lg font-medium",
          icon: :lg
        }
      }.freeze

      def initialize(
        allow_multiple: false,
        single_open: nil,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @allow_multiple = single_open.nil? ? allow_multiple : !single_open
        @size = size.to_sym
        @items = []

        validate_size!
      end

      def item(id:, title:, left_slot: nil, open: false, &block)
        @items << {
          id: id,
          title: title,
          left_slot: left_slot,
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

      def size_config
        SIZES.fetch(@size)
      end

      def render_item(item)
        content_tag(:div, class: "border-b border-[var(--accordion-item-border-color)] last:border-b-0") do
          safe_join([
            render_item_trigger(item),
            render_item_content(item)
          ])
        end
      end

      def render_item_trigger(item)
        content_tag(:button, **item_trigger_attributes(item)) do
          safe_join([
            render_item_label(item),
            render_item_icon
          ])
        end
      end

      def render_item_label(item)
        content_tag(:span, class: "flex items-center gap-2 min-w-0") do
          safe_join([
            render_item_left_slot(item),
            content_tag(:span, item[:title], class: size_config.fetch(:title))
          ].compact)
        end
      end

      def render_item_left_slot(item)
        return if item[:left_slot].blank?

        content_tag(:span, item[:left_slot].to_s, class: "shrink-0 inline-flex items-center leading-none")
      end

      def render_item_icon
        render FlatPack::Shared::IconComponent.new(
          name: "chevron-down",
          size: size_config.fetch(:icon),
          class: "transition-transform duration-[var(--duration-base)] ease-[var(--easing-standard)]",
          data: {"flat-pack--accordion-target": "icon"}
        )
      end

      def render_item_content(item)
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from components captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(:div, **item_content_attributes(item)) do
          content_tag(:div, item[:content].html_safe, class: size_config.fetch(:content_padding))
        end
      end

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--accordion",
            "flat-pack--accordion-allow-multiple-value": @allow_multiple
          },
          class: "border border-[var(--accordion-border-color)] rounded-[var(--accordion-border-radius)] overflow-hidden bg-[var(--accordion-background-color)]"
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
        "w-full flex items-center justify-between cursor-pointer #{size_config.fetch(:trigger_padding)} text-left text-[var(--accordion-trigger-text-color)] hover:bg-[var(--accordion-trigger-hover-background-color)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--accordion-focus-ring-color)] focus-visible:ring-inset"
      end

      def item_content_attributes(item)
        {
          id: item_content_id(item[:id]),
          class: "overflow-hidden transition-[max-height] duration-[var(--accordion-transition-duration)] ease-[var(--easing-standard)] bg-[var(--accordion-content-background-color)]",
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

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
