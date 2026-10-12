# frozen_string_literal: true

module FlatPack
  module Masonry
    class Image < FlatPack::BaseComponent
      def initialize(
        src:,
        alt:,
        width:,
        height:,
        href: nil,
        caption: nil,
        **system_arguments
      )
        super(**system_arguments)
        @src = FlatPack::AttributeSanitizer.sanitize_url(src)
        @alt = alt
        @width = width
        @height = height
        @href = href.present? ? FlatPack::AttributeSanitizer.sanitize_url(href) : nil
        @caption = caption

        validate_src!(src)
        validate_alt!
        validate_dimensions!
        @width = Integer(@width)
        @height = Integer(@height)
        validate_href!(href)
        validate_caption!
      end

      def call
        figure? ? render_figure : render_picture
      end

      private

      def render_figure
        content_tag(:figure, **merge_attributes(class: "fp-masonry__figure m-0")) do
          safe_join([
            render_picture,
            content_tag(:figcaption, @caption, class: figure_caption_classes)
          ])
        end
      end

      def render_picture
        return linked_image if @href.present?

        image_tag_html
      end

      def linked_image
        link_to(@href, class: "fp-masonry__link") { image_tag_html }
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

      def figure?
        @caption.present?
      end

      def image_classes
        classes(
          "fp-masonry__image",
          "block w-full h-auto",
          "rounded-[var(--radius-md)]"
        )
      end

      def figure_caption_classes
        "fp-masonry__caption mt-2 text-sm text-[var(--surface-muted-content-color)]"
      end

      def validate_src!(original)
        return if @src.present?

        raise ArgumentError, "Invalid src: #{original.inspect}. Must be an http(s) or relative URL."
      end

      def validate_alt!
        return if @alt.is_a?(String)

        raise ArgumentError, "alt must be a String"
      end

      def validate_dimensions!
        validate_dimension!(@width, :width)
        validate_dimension!(@height, :height)
      end

      def validate_dimension!(value, name)
        integer = Integer(value)
        return if integer.positive?

        raise ArgumentError, "#{name} must be a positive integer"
      rescue ArgumentError, TypeError
        raise ArgumentError, "#{name} must be a positive integer"
      end

      def validate_href!(original)
        return if original.blank? || @href.present?

        raise ArgumentError, "Invalid href: #{original.inspect}. Must be an http(s), mailto, tel, or relative URL."
      end

      def validate_caption!
        return if @caption.nil? || @caption.is_a?(String)

        raise ArgumentError, "caption must be a String"
      end
    end
  end
end
