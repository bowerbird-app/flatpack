# frozen_string_literal: true

module FlatPack
  module Collage
    class Item < FlatPack::BaseComponent
      ANGLE = /\A-?(?:\d+|\d*\.\d+)(?:deg|rad|turn|grad)\z/i
      LENGTH = /\A(?:-?(?:\d+|\d*\.\d+)(?:px|rem|em|%)|var\(--[a-z0-9-]+\))\z/i
      MAX_DEGREES = 180

      attr_writer :index, :motion

      def initialize(rotate: nil, offset: nil, z: nil, **system_arguments)
        super(**system_arguments)
        @rotate = normalize_rotate(rotate)
        @offset = normalize_offset(offset)
        @z = normalize_z(z)
      end

      def call
        content_tag(:div, item_body, **item_attributes)
      end

      # Unitless tilt and shift in -1..1. The same index always returns the same
      # triple, so a re-render does not reshuffle the collage.
      def self.units(index)
        {
          tilt: signed(mix(index, 1)),
          x: signed(mix(index, 2)),
          y: signed(mix(index, 3))
        }
      end

      def self.mix(index, salt)
        n = (((Integer(index) + 1) * 0x9E3779B9) ^ (salt * 0x85EBCA6B)) & 0xFFFFFFFF
        n = ((n ^ (n >> 16)) * 0x7FEB352D) & 0xFFFFFFFF
        n = ((n ^ (n >> 15)) * 0x846CA68B) & 0xFFFFFFFF
        (n ^ (n >> 16)) & 0xFFFF
      end
      private_class_method :mix

      def self.signed(value)
        ((value / 65535.0) * 2 - 1).round(2)
      end
      private_class_method :signed

      private

      def item_body
        return content unless motion?

        content_tag(:div, content, class: "fp-content-enter")
      end

      def item_attributes
        user_style = @system_arguments.delete(:style)
        merge_attributes(
          class: "fp-collage__item",
          style: join_styles(item_style, user_style)
        )
      end

      def item_style
        units = self.class.units(index)
        parts = [
          "--fp-collage-tilt: #{css_number(units[:tilt])}",
          "--fp-collage-shift-x: #{css_number(units[:x])}",
          "--fp-collage-shift-y: #{css_number(units[:y])}",
          "--fp-collage-index: #{index}",
          "--fp-collage-z: #{z_index}"
        ]
        parts << "--fp-collage-angle: #{@rotate}" if @rotate
        if @offset
          parts << "--fp-collage-x: #{@offset[0]}"
          parts << "--fp-collage-y: #{@offset[1]}"
        end
        parts.join("; ")
      end

      def index
        @index || 0
      end

      def motion?
        @motion != false
      end

      def z_index
        @z.nil? ? index + 1 : @z
      end

      def join_styles(*parts)
        joined = parts.compact.map { |part| part.to_s.strip }.reject(&:empty?).join("; ")
        joined.empty? ? nil : joined
      end

      def css_number(number)
        format("%.2f", number).sub(/0+\z/, "").sub(/\.\z/, "")
      end

      def normalize_rotate(rotate)
        return nil if rotate.nil?

        if rotate.is_a?(Numeric)
          degrees = rotate.to_f
          unless degrees.finite? && degrees.abs <= MAX_DEGREES
            raise ArgumentError, "Invalid rotate: #{rotate.inspect}. Use degrees from -#{MAX_DEGREES} to #{MAX_DEGREES}."
          end
          return "#{css_number(degrees)}deg"
        end

        string = rotate.to_s.strip
        return string if string.match?(ANGLE)

        raise ArgumentError, "Invalid rotate: #{rotate.inspect}. Use a number of degrees or a CSS angle."
      end

      def normalize_offset(offset)
        return nil if offset.nil?

        x, y = offset_pair(offset)
        [normalize_length(x), normalize_length(y)]
      end

      def offset_pair(offset)
        case offset
        when Array
          unless offset.size == 2
            raise ArgumentError, "Invalid offset: #{offset.inspect}. Pass [x, y]."
          end
          offset
        when Hash
          pair = [offset[:x] || offset["x"], offset[:y] || offset["y"]]
          if pair.any?(&:nil?)
            raise ArgumentError, "Invalid offset: #{offset.inspect}. Pass x and y."
          end
          pair
        else
          raise ArgumentError, "Invalid offset: #{offset.inspect}. Pass [x, y]."
        end
      end

      def normalize_length(length)
        return "#{css_number(length.to_f)}px" if length.is_a?(Numeric) && length.to_f.finite?

        string = length.to_s.strip
        return string if string.match?(LENGTH)

        raise ArgumentError, "Invalid offset: #{length.inspect}. Use a number of pixels or a CSS length."
      end

      def normalize_z(z)
        return nil if z.nil?
        return z if z.is_a?(Integer)

        raise ArgumentError, "Invalid z: #{z.inspect}. Use an integer."
      end
    end
  end
end
