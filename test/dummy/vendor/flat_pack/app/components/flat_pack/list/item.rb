# frozen_string_literal: true

module FlatPack
  module List
    class Item < FlatPack::BaseComponent
      def initialize(
        key: nil,
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
        @key_value = Rendering.key_value?
        @stack_below = Rendering.stack_below if @key_value
        @icon = icon
        @leading = leading
        @trailing = trailing
        @key = normalize_key(key)
        @href = sanitize_url(href)
        @hover = hover
        @active = active
        @link_arguments = sanitize_args(link_arguments || {})

        validate_layout_arguments!(href)
        validate_href!(href)
      end

      def call
        return render_key_value if @key_value

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
          content_tag(:span, "", class: "flat-pack-list-item-marker", aria: {hidden: true}),
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

        content_tag(:span, class: "flat-pack-list-item-icon flex-shrink-0 mr-2") do
          render_icon_graphic
        end
      end

      def render_icon_graphic
        if FlatPack::Shared::InlineSvg.markup?(@icon)
          # Trusted host markup only. Same as Button `icon:` starting with `<svg`.
          @icon.html_safe
        else
          render FlatPack::Shared::IconComponent.new(name: @icon, size: :md)
        end
      end

      def render_key_value
        content_tag(:div, **key_value_row_attributes) do
          safe_join([
            content_tag(:dt, class: key_value_term_classes) { render_key_value_term },
            content_tag(:dd, class: key_value_details_classes) { render_key_value_details }
          ])
        end
      end

      def render_key_value_term
        safe_join([
          render_key_value_icon,
          content_tag(:span, @key, class: key_label_classes)
        ])
      end

      def render_key_value_icon
        if @icon
          content_tag(:span, class: key_value_icon_classes, aria: {hidden: true}) do
            render_icon_graphic
          end
        else
          content_tag(:span, "", class: empty_icon_slot_classes, aria: {hidden: true})
        end
      end

      def render_key_value_details
        # SECURITY: Content is marked html_safe because it's expected to contain
        # Rails-generated HTML from components captured via block. Never pass
        # unsanitized user input directly to content.
        parts = [content_tag(:div, content.to_s.html_safe, class: "flat-pack-list-value min-w-0 flex-1 break-words")]
        parts << render_key_value_trailing if @trailing
        safe_join(parts)
      end

      def render_key_value_trailing
        content_tag(:span, @trailing, class: KeyValueLayout.trailing_classes_for(@stack_below))
      end

      def key_value_row_attributes
        merge_attributes(class: key_value_row_classes)
      end

      def key_value_row_classes
        classes(
          "flat-pack-list-key-value-row",
          KeyValueLayout.row_classes_for(@stack_below),
          "rounded-[var(--radius-sm)]",
          "py-[var(--list-item-padding-y)] px-[var(--list-item-padding-x)]",
          "text-[var(--surface-content-color)]",
          ("transition-colors hover:bg-[var(--list-item-hover-background-color)]" if @hover),
          ("bg-[var(--list-item-active-background-color)]" if @active)
        )
      end

      def key_value_term_classes
        KeyValueLayout.term_classes_for(@stack_below)
      end

      def key_label_classes
        "flat-pack-list-key min-w-0 break-words font-medium text-[var(--surface-muted-content-color)]"
      end

      def key_value_details_classes
        KeyValueLayout.details_classes_for(@stack_below)
      end

      def key_value_icon_classes
        "flat-pack-list-item-icon self-start mt-0.5 #{KeyValueLayout.icon_margin_class_for(@stack_below)}"
      end

      def empty_icon_slot_classes
        ["flat-pack-list-key-value-icon-slot", KeyValueLayout.empty_icon_slot_class_for(@stack_below)].compact.join(" ")
      end

      def normalize_key(key)
        return if key.nil?
        return key.strip if key.is_a?(String) && !value_html_safe?(key)

        raise ArgumentError, "key: must be a String."
      end

      def validate_layout_arguments!(href)
        if @key_value
          raise ArgumentError, "key: is required when the list layout is :key_value." if @key.blank?
          raise ArgumentError, "href: is not supported when the list layout is :key_value." if href.present?
          raise ArgumentError, "leading: is not supported when the list layout is :key_value." if @leading.present?
          return
        end

        return if @key.blank?

        raise ArgumentError, "key: is only supported when the list layout is :key_value."
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
          "rounded-[var(--radius-sm)]",
          "py-[var(--list-item-padding-y)] px-[var(--list-item-padding-x)]",
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
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-(--button-focus-ring-color)"
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
