# frozen_string_literal: true

module FlatPack
  module List
    class Item < FlatPack::BaseComponent
      def initialize(
        icon: nil,
        leading: nil,
        trailing: nil,
        href: nil,
        hover: false,
        active: false,
        link_arguments: {},
        **system_arguments
      )
        super(**system_arguments)
        @icon = icon
        @leading = leading
        @trailing = trailing
        @href = sanitize_url(href)
        @hover = hover
        @active = active
        @link_arguments = sanitize_args(link_arguments || {})

        validate_href!(href)
      end

      def call
        content_tag(:li, **item_attributes) do
          if linked?
            link_to @href, **link_attributes do
              render_item_content
            end
          else
            render_item_content
          end
        end
      end

      private

      def linked?
        @href.present?
      end

      def render_item_content
        safe_join([
          render_icon,
          render_leading,
          # SECURITY: Content is marked html_safe because it's expected to contain
          # Rails-generated HTML from components captured via block. Never pass
          # unsanitized user input directly to content.
          content_tag(:div, content.to_s.html_safe, class: "min-w-0 flex-1"),
          render_trailing
        ].compact)
      end

      def render_icon
        return unless @icon && @leading.nil?

        content_tag(:span, class: "flex-shrink-0 mr-2 text-[var(--surface-muted-content-color)]") do
          if @icon.is_a?(String) && @icon.start_with?("<svg")
            @icon.html_safe
          else
            content_tag(:svg, class: "w-5 h-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
              content_tag(:use, nil, "xlink:href": "#icon-#{@icon}")
            end
          end
        end
      end

      def render_leading
        return unless @leading
        content_tag(:span, @leading, class: "flex-shrink-0 mr-2")
      end

      def render_trailing
        return unless @trailing
        content_tag(:span, @trailing, class: "flex-shrink-0 ml-2")
      end

      def item_attributes
        merge_attributes(
          class: item_classes,
          role: "listitem"
        )
      end

      def item_classes
        classes(
          "flex items-start",
          "py-2 px-3",
          "rounded-[var(--radius-sm)]",
          "text-[var(--surface-content-color)]",
          ("transition-colors hover:bg-[var(--list-item-hover-background-color)]" if @hover),
          ("bg-[var(--list-item-active-background-color)]" if @active)
        )
      end

      def link_attributes
        link_data = @link_arguments.fetch(:data, {})
        link_aria = @link_arguments.fetch(:aria, {})
        link_html_attributes = @link_arguments.except(:class, :data, :aria)

        {
          class: merge_class_names(link_classes, @link_arguments[:class]),
          data: link_data,
          aria: link_aria
        }.merge(link_html_attributes).compact
      end

      def link_classes
        classes(
          "flat-pack-list-item-link",
          "flex w-full items-start",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-(--button-focus-ring-color)"
        )
      end

      def merge_class_names(*class_names)
        TailwindMerge::Merger.new.merge(class_names.compact.join(" "))
      end

      def sanitize_url(url)
        return nil if url.nil?

        FlatPack::AttributeSanitizer.sanitize_url(url)
      end

      def validate_href!(original_url)
        return unless original_url.present?
        return if @href.present?

        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
