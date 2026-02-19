# frozen_string_literal: true

module FlatPack
  module TopNav
    class Component < FlatPack::BaseComponent
      renders_one :left_slot
      renders_one :center_slot
      renders_one :right_slot

      def left(**args, &block)
        return left_slot unless block

        with_left_slot(**args, &block)
      end

      def center(**args, &block)
        return center_slot unless block

        with_center_slot(**args, &block)
      end

      def right(**args, &block)
        return right_slot unless block

        with_right_slot(**args, &block)
      end

      def left?
        left_slot?
      end

      def center?
        center_slot?
      end

      def right?
        right_slot?
      end

      def call
        content_tag(:header, **header_attributes) do
          content_tag(:div, class: container_classes) do
            safe_join([
              (render_section(left, "left") if left?),
              (render_section(center, "center") if center?),
              (render_section(right, "right") if right?)
            ].compact)
          end
        end
      end

      private

      def render_section(slot_content, alignment)
        content_tag(:div, slot_content.to_s, class: section_classes(alignment))
      end

      def header_attributes
        merge_attributes(
          class: header_classes,
          style: header_style
        )
      end

      def header_style
        existing_style = @system_arguments[:style]
        [existing_style, "height: 72px"].compact.join("; ")
      end

      def header_classes
        classes(
          "sticky",
          "top-0",
          "z-10",
          "bg-[var(--color-background)]/80",
          "backdrop-blur-lg",
          "border-[var(--color-border)]",
          "px-4",
          "py-0"
        )
      end

      def container_classes
        "h-full flex items-center gap-4"
      end

      def section_classes(alignment)
        case alignment
        when "left"
          "h-full flex items-center gap-2"
        when "center"
          "h-full flex-1 flex items-center justify-center"
        when "right"
          "h-full flex items-center gap-2"
        end
      end
    end
  end
end
