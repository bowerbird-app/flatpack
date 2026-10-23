# frozen_string_literal: true

module FlatPack
  module TopNav
    class Component < FlatPack::BaseComponent
      renders_one :left_slot
      renders_one :center_slot
      renders_one :right_slot

      undef_method :with_left_slot, :with_left_slot_content,
        :with_center_slot, :with_center_slot_content,
        :with_right_slot, :with_right_slot_content

      SECTIONS = %w[left center right].freeze
      REMOVED_KEYWORDS = %i[mobile_menu mobile_menu_label mobile_breakpoint].freeze

      def initialize(**system_arguments)
        reject_removed!(system_arguments)
        super
      end

      def left(**args, &block)
        return left_slot unless block

        reject_removed_slot_keywords!(args)
        set_slot(:left_slot, nil, **args, &block)
      end

      def center(**args, &block)
        return center_slot unless block

        reject_removed_slot_keywords!(args)
        set_slot(:center_slot, nil, **args, &block)
      end

      def right(**args, &block)
        return right_slot unless block

        reject_removed_slot_keywords!(args)
        set_slot(:right_slot, nil, **args, &block)
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
              render_section(left, "left"),
              render_section(center, "center"),
              render_section(right, "right")
            ])
          end
        end
      end

      private

      def render_section(slot_content, alignment)
        content_tag(
          :div,
          slot_content.to_s,
          class: section_classes(alignment),
          data: {"flat-pack-top-nav-section": alignment}
        )
      end

      def header_attributes
        attrs = merge_attributes(class: header_classes)
        attrs[:data] = merge_data_attributes(
          attrs[:data],
          {
            controller: "flat-pack--top-nav",
            scrolled: "false"
          }
        )
        attrs
      end

      def header_classes
        classes(
          "fp-top-nav",
          "sticky",
          "top-0",
          "z-10",
          "bg-[var(--top-nav-background-color)]"
        )
      end

      def container_classes
        "h-full min-w-0 w-full flex items-center gap-4"
      end

      def reject_removed!(arguments)
        removed = arguments.keys & REMOVED_KEYWORDS
        return if removed.empty?

        raise ArgumentError, "unknown keyword: :#{removed.first}"
      end

      def reject_removed_slot_keywords!(args)
        return unless args.key?(:always_display)

        raise ArgumentError, "unknown keyword: :always_display"
      end

      def section_classes(alignment)
        case alignment
        when "left"
          "h-full min-w-0 flex items-center gap-2"
        when "center"
          "h-full min-w-0 flex-1 flex items-center justify-center"
        when "right"
          "h-full min-w-0 flex items-center justify-end gap-2"
        end
      end
    end
  end
end
