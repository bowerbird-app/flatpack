# frozen_string_literal: true

module FlatPack
  module Media
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "group/media" "w-full" "block" "h-auto" "max-w-full" "object-cover"
      # "rounded-[var(--media-radius)]" "bg-[var(--surface-muted-background-color)]"
      # "outline" "outline-1" "-outline-offset-1" "outline-[var(--media-outline-color)]"
      # "opacity-0" "opacity-100" "group-hover/media:opacity-100" "focus-within:opacity-100"
      # "transition-opacity" "duration-[var(--duration-fast)]" "ease-[var(--easing-standard)]"
      # "motion-reduce:transition-none"

      # Slot carrier. Placement and inset are applied by FlatPack::Overlay::Item.
      class Item < ViewComponent::Base
        attr_reader :placement, :inset, :system_arguments

        def initialize(placement: :top_left, inset: :md, **system_arguments)
          @placement = placement
          @inset = inset
          @system_arguments = system_arguments
        end

        def call
          content
        end
      end

      renders_many :items, Item

      def initialize(src:, alt:, width:, height:, **system_arguments)
        if system_arguments.key?(:href) || system_arguments.key?(:caption)
          raise ArgumentError, "Media does not take href or caption. Wrap a link in the host and put the filename beside the image."
        end

        super(**system_arguments)
        @src = FlatPack::AttributeSanitizer.sanitize_url(src)
        @alt = alt
        @width = positive_integer!(width, :width)
        @height = positive_integer!(height, :height)

        validate_src!(src)
        validate_alt!
      end

      def call
        render(FlatPack::Overlay::Component.new(**overlay_arguments)) do |overlay|
          overlay.with_media { image_tag_html }
          forward_items(overlay)
        end
      end

      private

      def overlay_arguments
        attributes = merge_attributes(class: "w-full")
        attributes[:class] = "#{attributes[:class]} group/media"
        attributes
      end

      def forward_items(overlay)
        items.each do |item|
          overlay.with_item(placement: item.placement, inset: item.inset, **item.system_arguments) do
            item.to_s
          end
        end
      end

      def image_tag_html
        tag.img(
          src: @src,
          alt: @alt,
          width: @width,
          height: @height,
          loading: "lazy",
          decoding: "async",
          class: image_classes,
          style: "aspect-ratio: #{@width} / #{@height}"
        )
      end

      def image_classes
        [
          "fp-media__image",
          "block",
          "h-auto",
          "w-full",
          "max-w-full",
          "object-cover",
          "rounded-[var(--media-radius)]",
          "bg-[var(--surface-muted-background-color)]",
          "outline",
          "outline-1",
          "-outline-offset-1",
          "outline-[var(--media-outline-color)]"
        ].join(" ")
      end

      def validate_src!(original)
        return if @src.present?

        raise ArgumentError, "Invalid src: #{original.inspect}. Must be an http(s) or relative URL."
      end

      def validate_alt!
        return if @alt.is_a?(String)

        raise ArgumentError, "alt must be a String"
      end

      def positive_integer!(value, name)
        integer = case value
        when Integer
          value
        when String
          Integer(value, 10)
        else
          raise ArgumentError, "#{name} must be a positive integer"
        end

        raise ArgumentError, "#{name} must be a positive integer" unless integer.positive?

        integer
      rescue ArgumentError
        raise ArgumentError, "#{name} must be a positive integer"
      end
    end
  end
end
