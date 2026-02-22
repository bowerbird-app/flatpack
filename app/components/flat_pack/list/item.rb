# frozen_string_literal: true

module FlatPack
  module List
    class Item < FlatPack::BaseComponent
      def initialize(
        icon: nil,
        leading: nil,
        trailing: nil,
        **system_arguments
      )
        super(**system_arguments)
        @icon = icon
        @leading = leading
        @trailing = trailing
      end

      def call
        content_tag(:li, **item_attributes) do
          safe_join([
            render_icon,
            render_leading,
            # SECURITY: Content is marked html_safe because it's expected to contain
            # Rails-generated HTML from components captured via block. Never pass
            # unsanitized user input directly to content.
            content_tag(:span, content.to_s.html_safe, class: "flex-1"),
            render_trailing
          ].compact)
        end
      end

      private

      def render_icon
        return unless @icon && @leading.nil?

        content_tag(:span, class: "flex-shrink-0 mr-2 text-muted-foreground") do
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
          "text-foreground"
        )
      end
    end
  end
end
