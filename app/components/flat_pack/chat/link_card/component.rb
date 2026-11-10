# frozen_string_literal: true

module FlatPack
  module Chat
    module LinkCard
      class Component < FlatPack::BaseComponent
        DIRECTIONS = {
          incoming: "justify-start",
          outgoing: "justify-end"
        }.freeze

        def initialize(
          title:,
          href: nil,
          description: nil,
          meta: nil,
          icon: nil,
          direction: :incoming,
          **system_arguments
        )
          super(**system_arguments)
          @title = title
          @href = href.to_s.strip.presence
          @description = description
          @meta = meta
          @icon = icon
          @direction = direction.to_sym

          validate_title!
          validate_description!
          validate_meta!
          validate_direction!
        end

        def call
          content_tag(:div, **wrapper_attributes) do
            content_tag(card_tag, **card_attributes) do
              safe_join([
                render_icon,
                content_tag(:div, class: "min-w-0 flex-1") do
                  safe_join([
                    content_tag(:div, @title, class: title_classes),
                    (@description.present? ? content_tag(:div, @description, class: description_classes) : nil),
                    (meta_text.present? ? content_tag(:div, meta_text, class: meta_classes) : nil)
                  ].compact)
                end
              ].compact)
            end
          end
        end

        private

        def linked?
          @href.present?
        end

        def card_tag
          linked? ? :a : :div
        end

        def meta_text
          return @meta if @meta.present?
          return fp_t("chat.link_card.unavailable") unless linked?

          nil
        end

        def wrapper_attributes
          merge_attributes(
            class: "flex #{DIRECTIONS.fetch(@direction)}"
          )
        end

        def card_attributes
          attrs = {
            class: card_classes,
            data: {
              flat_pack_chat_link_card: true,
              flat_pack_chat_link_card_available: linked?
            }
          }
          attrs[:href] = @href if linked?
          attrs
        end

        def card_classes
          [
            "flex min-w-0 max-w-[75%] sm:max-w-[500px] items-start gap-3",
            "rounded-[var(--chat-link-card-radius)]",
            "px-[var(--chat-link-card-padding-x)]",
            "py-[var(--chat-link-card-padding-y)]",
            "border border-[var(--surface-border-color)]",
            "no-underline",
            linked? ? linked_surface_classes : unavailable_surface_classes
          ].join(" ")
        end

        def linked_surface_classes
          "bg-[var(--surface-background-color)] text-[var(--surface-content-color)] cursor-pointer hover:bg-[var(--surface-hover-background-color)] transition-colors duration-[var(--duration-fast)] ease-[var(--easing-standard)] focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-[var(--color-ring)]"
        end

        def unavailable_surface_classes
          "bg-[var(--surface-muted-background-color)] text-[var(--surface-muted-content-color)]"
        end

        def title_classes
          tone = linked? ? "text-[var(--surface-content-color)]" : "text-[var(--surface-muted-content-color)]"
          "truncate text-sm font-medium #{tone}"
        end

        def description_classes
          "mt-0.5 line-clamp-2 text-sm text-[var(--surface-muted-content-color)]"
        end

        def meta_classes
          "mt-1 text-xs text-[var(--surface-muted-content-color)]"
        end

        def render_icon
          return unless @icon.present?

          content_tag(:div, class: "flex-shrink-0 mt-0.5 text-[var(--surface-muted-content-color)]") do
            render FlatPack::Shared::IconComponent.new(name: @icon, size: :md)
          end
        end

        def validate_title!
          validate_text_option!(@title, name: :title)
          return if @title.present?

          raise ArgumentError, "title is required"
        end

        def validate_description!
          validate_text_option!(@description, name: :description)
        end

        def validate_meta!
          validate_text_option!(@meta, name: :meta)
        end

        def validate_direction!
          return if DIRECTIONS.key?(@direction)

          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: #{DIRECTIONS.keys.join(", ")}"
        end
      end
    end
  end
end
