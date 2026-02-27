# frozen_string_literal: true

module FlatPack
  module Chat
    module ImageDeck
      class Component < FlatPack::BaseComponent
        DEFAULT_MAX_VISIBLE = 3
        DEFAULT_CARD_WIDTH = 208
        DEFAULT_CARD_HEIGHT = 224
        DEFAULT_OVERLAP_X = 14
        # Keep horizontal and vertical stepping equal so lower cards do not
        # appear to jump farther than intermediate cards.
        DEFAULT_OVERLAP_Y = 14

        def initialize(
          images:,
          direction: :incoming,
          max_visible: DEFAULT_MAX_VISIBLE,
          overlap_x: DEFAULT_OVERLAP_X,
          overlap_y: DEFAULT_OVERLAP_Y,
          bordered: true,
          **system_arguments
        )
          super(**system_arguments)
          @images = normalize_images(images)
          @direction = normalize_direction(direction)
          @max_visible = normalize_positive_integer(max_visible, DEFAULT_MAX_VISIBLE)
          @overlap_x = normalize_positive_integer(overlap_x, DEFAULT_OVERLAP_X)
          @overlap_y = normalize_positive_integer(overlap_y, DEFAULT_OVERLAP_Y)
          @bordered = bordered

          validate_images!
        end

        def call
          content_tag(:div, **deck_attributes) do
            safe_join([
              render_cards,
              (render_overflow_badge if overflow_count.positive?)
            ].compact)
          end
        end

        private

        def visible_images
          @visible_images ||= @images.first(@max_visible)
        end

        def overflow_count
          @images.length - visible_images.length
        end

        def render_cards
          cards = visible_images.each_with_index.to_a.reverse.map do |(image, index)|
            render_card(image, index)
          end

          safe_join(cards)
        end

        def render_card(image, index)
          content_tag(
            :div,
            class: card_classes,
            style: card_style(index),
            data: {
              flat_pack__chat_image_deck_target: "card",
              flat_pack_chat_image_deck_index: index
            }
          ) do
            image_tag = content_tag(
              :img,
              nil,
              src: image[:thumbnail_url],
              alt: image[:name],
              loading: "lazy",
              class: "h-full w-full object-cover"
            )

            if image[:href].present?
              content_tag(:a, image_tag, href: image[:href], target: "_blank", rel: "noopener noreferrer", class: "block h-full w-full")
            else
              image_tag
            end
          end
        end

        def render_overflow_badge
          render FlatPack::Badge::Component.new(
            text: "+#{overflow_count}",
            style: :default,
            size: :lg,
            class: overflow_badge_classes
          )
        end

        def deck_attributes
          merge_attributes(
            class: classes("relative", direction_alignment_class),
            style: "width: #{deck_width}px; height: #{deck_height}px;",
            data: {
              controller: "flat-pack--chat-image-deck",
              action: "pointerenter->flat-pack--chat-image-deck#fanOut pointerleave->flat-pack--chat-image-deck#collapse mouseenter->flat-pack--chat-image-deck#fanOut mouseleave->flat-pack--chat-image-deck#collapse focusin->flat-pack--chat-image-deck#fanOut focusout->flat-pack--chat-image-deck#collapseOnFocusOut pointerdown->flat-pack--chat-image-deck#handlePointerDown",
              flat_pack_chat_image_deck: true,
              flat_pack_chat_image_deck_direction: @direction,
              flat_pack_chat_image_deck_count: @images.length,
              flat_pack_chat_image_deck_overlap_x: @overlap_x,
              flat_pack_chat_image_deck_overlap_y: @overlap_y
            }
          )
        end

        def card_classes
          classes(
            "absolute top-0 overflow-hidden rounded-2xl",
            ("border border-[var(--chat-attachment-border-color)]" if @bordered),
            "bg-[var(--surface-background-color)]",
            "shadow-md",
            "transition-transform duration-200 ease-out",
            "will-change-transform"
          )
        end

        def card_style(index)
          x_offset = @overlap_x * index
          y_offset = @overlap_y * index
          horizontal_property = (@direction == :incoming) ? "left" : "right"
          horizontal_transform = (@direction == :incoming) ? x_offset : -x_offset

          [
            "#{horizontal_property}: 0",
            "width: #{DEFAULT_CARD_WIDTH}px",
            "height: #{DEFAULT_CARD_HEIGHT}px",
            "transform: translate(#{horizontal_transform}px, #{y_offset}px)",
            "z-index: #{visible_images.length - index}"
          ].join("; ")
        end

        def overflow_badge_classes
          side_class = (@direction == :incoming) ? "right-2" : "left-2"

          classes(
            "absolute top-2 z-50",
            side_class,
            "leading-none"
          )
        end

        def direction_alignment_class
          (@direction == :incoming) ? "mr-auto" : "ml-auto"
        end

        def deck_width
          DEFAULT_CARD_WIDTH + (@overlap_x * (visible_images.length - 1))
        end

        def deck_height
          DEFAULT_CARD_HEIGHT + (@overlap_y * (visible_images.length - 1))
        end

        def normalize_images(images)
          Array(images).filter_map do |image|
            if image.is_a?(Hash)
              {
                name: image[:name] || image["name"] || "Image",
                thumbnail_url: image[:thumbnail_url] || image["thumbnail_url"],
                href: image[:href] || image["href"]
              }
            else
              {
                name: image.respond_to?(:name) ? image.name : "Image",
                thumbnail_url: image.respond_to?(:thumbnail_url) ? image.thumbnail_url : nil,
                href: nil
              }
            end
          end.select { |image| image[:thumbnail_url].present? }
        end

        def normalize_direction(value)
          value.to_sym
        rescue NoMethodError
          :incoming
        end

        def normalize_positive_integer(value, fallback)
          parsed = Integer(value, 10)
          parsed.positive? ? parsed : fallback
        rescue ArgumentError, TypeError
          fallback
        end

        def validate_images!
          raise ArgumentError, "images must include at least one thumbnail" if @images.empty?
          return if %i[incoming outgoing].include?(@direction)

          raise ArgumentError, "direction must be :incoming or :outgoing"
        end
      end
    end
  end
end
