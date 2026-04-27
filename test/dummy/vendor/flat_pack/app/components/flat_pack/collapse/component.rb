# frozen_string_literal: true

module FlatPack
  module Collapse
    class Component < FlatPack::BaseComponent
      def initialize(
        id:,
        title:,
        open: false,
        **system_arguments
      )
        super(**system_arguments)
        @id = id
        @title = title
        @open = open

        validate_id!
        validate_title!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_trigger,
            render_content
          ])
        end
      end

      private

      def render_trigger
        content_tag(:button, **trigger_attributes) do
          safe_join([
            content_tag(:span, @title, class: "font-medium"),
            render_icon
          ])
        end
      end

      def render_icon
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          class: "w-5 h-5 transition-transform duration-200 text-[var(--collapse-icon-color)]",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor",
          data: {"flat-pack--collapse-target": "icon"}) do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M19 9l-7 7-7-7"
          )
        end
      end

      def render_content
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from components captured via block. Never pass
        # unsanitized user input directly to content.
        content_tag(:div, **content_attributes) do
          content_tag(:div, content.to_s.html_safe, class: "p-[var(--collapse-content-padding)]")
        end
      end

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--collapse",
            "flat-pack--collapse-open-value": @open
          },
          class: "border border-[var(--collapse-border-color)] rounded-[var(--collapse-border-radius)] overflow-hidden bg-[var(--collapse-background-color)]"
        )
      end

      def trigger_attributes
        {
          type: "button",
          class: trigger_classes,
          aria: {
            expanded: @open,
            controls: content_id
          },
          data: {
            "flat-pack--collapse-target": "trigger",
            action: "flat-pack--collapse#toggle"
          }
        }
      end

      def trigger_classes
        "w-full flex items-center justify-between p-[var(--collapse-trigger-padding)] text-left text-[var(--collapse-trigger-text-color)] bg-[var(--collapse-trigger-background-color)] hover:bg-[var(--collapse-trigger-hover-background-color)] transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--collapse-focus-ring-color)] focus-visible:ring-offset-2"
      end

      def content_attributes
        {
          id: content_id,
          class: "overflow-hidden transition-all duration-[var(--collapse-transition-duration)] ease-in-out bg-[var(--collapse-content-background-color)]",
          data: {"flat-pack--collapse-target": "content"},
          hidden: !@open
        }
      end

      def content_id
        "#{@id}-content"
      end

      def validate_id!
        return if @id.present?
        raise ArgumentError, "id is required"
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end
    end
  end
end
