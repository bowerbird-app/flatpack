# frozen_string_literal: true

module FlatPack
  module CommandPalette
    class Component < FlatPack::BaseComponent
      def initialize(
        id:,
        items:,
        placeholder: "Search commands",
        empty_text: "No matching commands",
        shortcut: true,
        **system_arguments
      )
        super(**system_arguments)
        @palette_id = id
        @items = Array(items)
        @placeholder = placeholder
        @empty_text = empty_text
        @shortcut = shortcut
        validate_id!
        validate_items!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_backdrop,
            render_dialog
          ])
        end
      end

      private

      def grouped_items
        @items.group_by { |item| item[:group].presence || "Commands" }
      end

      def root_attributes
        merge_attributes(
          id: @palette_id,
          class: root_classes,
          data: {
            controller: "flat-pack--command-palette",
            "flat-pack--command-palette-shortcut-value": @shortcut,
            action: "keydown.esc->flat-pack--command-palette#close keydown->flat-pack--command-palette#trapTab"
          },
          aria: {hidden: "true"}
        )
      end

      def root_classes
        classes(
          "fixed inset-0 z-50 hidden fp-overlay-pad",
          "bg-[var(--modal-backdrop-color)]",
          "backdrop-blur-[var(--modal-backdrop-blur)]",
          "transition-opacity duration-[var(--duration-slow)] ease-[var(--easing-enter)]"
        )
      end

      def render_backdrop
        content_tag(:div, nil, class: "absolute inset-0", data: {action: "click->flat-pack--command-palette#clickBackdrop"})
      end

      def render_dialog
        content_tag(:div, **dialog_attributes) do
          safe_join([
            render_search_row,
            render_results
          ])
        end
      end

      def dialog_attributes
        {
          role: "dialog",
          aria: {modal: "true", label: "Command palette"},
          class: dialog_classes,
          data: {"flat-pack--command-palette-target": "dialog"}
        }
      end

      def dialog_classes
        [
          "relative mx-auto mt-[12vh] w-full max-w-lg",
          "overflow-hidden rounded-[var(--radius-lg)]",
          "border border-[var(--modal-border-color)]",
          "bg-[var(--modal-surface-color)] shadow-lg",
          "opacity-0 scale-95 motion-reduce:scale-100",
          "transition-[opacity,scale] duration-[var(--duration-slow)] ease-[var(--easing-enter)]"
        ].join(" ")
      end

      def render_search_row
        content_tag(:div, class: "flex items-center gap-2 border-b border-[var(--surface-border-color)] px-4 py-3") do
          safe_join([
            content_tag(:span, class: "text-[var(--surface-muted-content-color)]", "aria-hidden": "true") do
              render FlatPack::Shared::IconComponent.new(name: "magnifying-glass", size: :sm)
            end,
            content_tag(:input, nil, **search_attributes),
            render(FlatPack::Kbd::Component.new(keys: ["Esc"]))
          ])
        end
      end

      def search_attributes
        {
          type: "search",
          placeholder: @placeholder,
          autocomplete: "off",
          class: "min-w-0 flex-1 bg-transparent text-sm text-[var(--surface-content-color)] placeholder:text-[var(--surface-muted-content-color)] outline-none",
          data: {
            "flat-pack--command-palette-target": "input",
            action: "input->flat-pack--command-palette#filter keydown->flat-pack--command-palette#keydown"
          }
        }
      end

      def render_results
        content_tag(:div, class: "max-h-80 overflow-y-auto py-2", data: {"flat-pack--command-palette-target": "results"}) do
          safe_join(grouped_items.map { |group, items| render_group(group, items) } + [render_empty_row])
        end
      end

      def render_group(group, items)
        content_tag(:div, class: "px-2", data: {"flat-pack--command-palette-target": "group"}) do
          safe_join([
            content_tag(:p, group, class: "px-2 py-1 text-xs font-medium text-[var(--surface-muted-content-color)]"),
            content_tag(:ul, role: "listbox") do
              safe_join(items.map { |item| render_item(item) })
            end
          ])
        end
      end

      def render_item(item)
        href = item[:href].present? ? FlatPack::AttributeSanitizer.sanitize_url(item[:href]) : nil
        content_tag(:li) do
          inner = safe_join([
            render_item_icon(item),
            content_tag(:span, item[:label].to_s, class: "min-w-0 flex-1"),
            (render(FlatPack::Kbd::Component.new(keys: Array(item[:hint]))) if item[:hint].present?)
          ].compact)

          if href.present?
            content_tag(:a, inner, **item_attributes(item, href: href))
          else
            content_tag(:button, inner, **item_attributes(item, href: nil).merge(type: "button"))
          end
        end
      end

      def item_attributes(item, href:)
        attributes = {
          role: "option",
          class: item_classes,
          data: {
            "flat-pack--command-palette-target": "item",
            search: [item[:label], item[:group], Array(item[:hint]).join(" ")].compact.join(" ").downcase,
            action: "click->flat-pack--command-palette#choose"
          }
        }
        attributes[:href] = href if href.present?
        attributes
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "hover:bg-[var(--list-item-hover-background-color)]" "aria-selected:bg-[var(--list-item-active-background-color)]"
      def item_classes
        [
          "flex items-center gap-3 rounded-[var(--radius-md)] px-2 py-2 text-sm",
          "text-[var(--surface-content-color)]",
          "hover:bg-[var(--list-item-hover-background-color)]",
          "aria-selected:bg-[var(--list-item-active-background-color)]"
        ].join(" ")
      end

      def render_item_icon(item)
        return unless item[:icon].present?

        content_tag(:span, class: "text-[var(--surface-muted-content-color)]", "aria-hidden": "true") do
          render FlatPack::Shared::IconComponent.new(name: item[:icon], size: :sm)
        end
      end

      def render_empty_row
        content_tag(:p,
          @empty_text,
          class: "hidden px-4 py-6 text-sm text-[var(--surface-muted-content-color)]",
          data: {"flat-pack--command-palette-target": "empty"})
      end

      def validate_id!
        return if @palette_id.present?

        raise ArgumentError, "id is required"
      end

      def validate_items!
        return if @items.any? && @items.all? { |item| item.is_a?(Hash) && item[:label].present? }

        raise ArgumentError, "items must be an array of hashes with label:"
      end
    end
  end
end
