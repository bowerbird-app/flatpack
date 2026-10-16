# frozen_string_literal: true

module FlatPack
  module AnimatedCharacter
    # Turns a caller hash into the only shape the renderer and the motion
    # controller will read. Anything else raises.
    class Definition
      SHAPES = {
        "circle" => %w[cx cy r fill stroke stroke-width stroke-linecap stroke-linejoin opacity].freeze,
        "ellipse" => %w[cx cy rx ry fill stroke stroke-width stroke-linecap stroke-linejoin opacity].freeze,
        "rect" => %w[x y width height rx ry fill stroke stroke-width stroke-linecap stroke-linejoin opacity].freeze,
        "path" => %w[d fill stroke stroke-width stroke-linecap stroke-linejoin fill-rule opacity].freeze,
        "line" => %w[x1 y1 x2 y2 stroke stroke-width stroke-linecap opacity].freeze,
        "polyline" => %w[points fill stroke stroke-width stroke-linecap stroke-linejoin opacity].freeze
      }.freeze

      NUMERIC_ATTRS = %w[cx cy r rx ry x y width height x1 y1 x2 y2 stroke-width opacity].freeze
      PAINT_ATTRS = %w[fill stroke].freeze
      ENUM_ATTRS = {
        "stroke-linecap" => %w[butt round square].freeze,
        "stroke-linejoin" => %w[miter round bevel].freeze,
        "fill-rule" => %w[nonzero evenodd].freeze
      }.freeze
      PROPERTIES = %w[translateX translateY scaleX scaleY rotate opacity strokeDashoffset].freeze
      EASINGS = %w[standard enter exit linear].freeze
      DURATION_TOKENS = %w[fast base slow].freeze
      SPECIAL_PARTS = %w[root strokes].freeze
      PART_KEYS = %w[name shapes parts opacity].freeze
      TRACK_KEYS = %w[part property keyframes duration delay easing iterations].freeze
      KEYFRAME_KEYS = %w[value offset].freeze

      PART_NAME = /\A[a-z][a-z0-9-]*\z/
      VIEW_BOX = /\A-?\d+(?:\.\d+)?(?:\s+-?\d+(?:\.\d+)?){3}\z/
      PAINT = /\A(?:none|currentColor|#[0-9a-fA-F]{3,8}|var\(--[a-z0-9-]+\))\z/
      PATH_D = /\A[MmZzLlHhVvCcSsQqTtAaEe0-9\s,.\-+]+\z/
      POINTS = /\A-?\d+(?:\.\d+)?(?:[\s,]+-?\d+(?:\.\d+)?)*\z/

      class << self
        def sanitize(raw)
          new(raw).sanitize
        end
      end

      def initialize(raw)
        raise ArgumentError, "definition must be a Hash" unless raw.is_a?(Hash)

        @raw = stringify(raw)
      end

      def sanitize
        parts = sanitize_parts(@raw["parts"] || [])
        names = part_names(parts)
        {
          "view_box" => sanitize_view_box(@raw["view_box"], parts),
          "parts" => parts,
          "states" => sanitize_states(@raw["states"], names)
        }.compact
      end

      private

      def stringify(value)
        case value
        when Hash
          value.each_with_object({}) { |(key, nested), copy| copy[key.to_s] = stringify(nested) }
        when Array
          value.map { |nested| stringify(nested) }
        else
          value
        end
      end

      def sanitize_view_box(value, parts)
        if value.nil?
          raise ArgumentError, "view_box is required" if parts.any?

          return nil
        end

        view_box = value.to_s
        return view_box if view_box.match?(VIEW_BOX)

        raise ArgumentError, "view_box must be four numbers"
      end

      def sanitize_parts(parts)
        raise ArgumentError, "parts must be an Array" unless parts.is_a?(Array)

        parts.map { |part| sanitize_part(part) }
      end

      def sanitize_part(part)
        raise ArgumentError, "a part must be a Hash" unless part.is_a?(Hash)

        unknown = part.keys - PART_KEYS
        raise ArgumentError, "unknown part key: #{unknown.join(", ")}" if unknown.any?

        name = part["name"].to_s
        raise ArgumentError, "part name #{name.inspect} is not allowed" unless name.match?(PART_NAME)

        shapes = part["shapes"] || []
        children = part["parts"] || []
        raise ArgumentError, "part #{name} needs shapes or nested parts" if shapes.empty? && children.empty?

        sanitized = {
          "name" => name,
          "shapes" => sanitize_shapes(shapes, name),
          "parts" => sanitize_parts(children)
        }
        sanitized["opacity"] = unit_number(part["opacity"], "opacity") if part.key?("opacity")
        sanitized
      end

      def sanitize_shapes(shapes, part_name)
        raise ArgumentError, "shapes on #{part_name} must be an Array" unless shapes.is_a?(Array)

        shapes.map { |shape| sanitize_shape(shape) }
      end

      def sanitize_shape(shape)
        raise ArgumentError, "a shape must be a Hash" unless shape.is_a?(Hash)

        shape = {"type" => shape["type"]}.merge(shape["attrs"]) if shape.keys == %w[type attrs] || shape.keys.sort == %w[attrs type]
        type = shape["type"].to_s
        allowed = SHAPES[type]
        raise ArgumentError, "unknown shape #{type.inspect}" unless allowed

        attrs = shape.except("type")
        unknown = attrs.keys - allowed
        raise ArgumentError, "unknown attribute #{unknown.join(", ")} on #{type}" if unknown.any?

        {"type" => type, "attrs" => attrs.to_h { |key, value| [key, sanitize_attr(type, key, value)] }}
      end

      def sanitize_attr(type, key, value)
        return number!(value, key) if NUMERIC_ATTRS.include?(key)
        return sanitize_paint(value, key) if PAINT_ATTRS.include?(key)
        return sanitize_enum(key, value) if ENUM_ATTRS.key?(key)
        return sanitize_path(value) if key == "d"
        return sanitize_points(value) if key == "points"

        raise ArgumentError, "unknown attribute #{key} on #{type}"
      end

      def sanitize_paint(value, key)
        paint = value.to_s
        return paint if paint.match?(PAINT)

        raise ArgumentError, "#{key} #{paint.inspect} is not a safe paint"
      end

      def sanitize_enum(key, value)
        choice = value.to_s
        return choice if ENUM_ATTRS.fetch(key).include?(choice)

        raise ArgumentError, "#{key} must be one of: #{ENUM_ATTRS.fetch(key).join(", ")}"
      end

      def sanitize_path(value)
        path = value.to_s
        return path if path.match?(PATH_D)

        raise ArgumentError, "path d has unsupported characters"
      end

      def sanitize_points(value)
        points = value.to_s
        return points if points.match?(POINTS)

        raise ArgumentError, "polyline points must be numbers"
      end

      def part_names(parts, found = [])
        parts.each do |part|
          raise ArgumentError, "duplicate part #{part["name"]}" if found.include?(part["name"])

          found << part["name"]
          part_names(part["parts"], found)
        end
        found
      end

      def sanitize_states(states, names)
        raise ArgumentError, "states must be a Hash" unless states.is_a?(Hash)
        raise ArgumentError, "states must include at least one state" if states.empty?

        states.each_with_object({}) do |(name, state), copy|
          raise ArgumentError, "state name #{name.inspect} is not allowed" unless name.match?(PART_NAME)
          raise ArgumentError, "state #{name} must be a Hash" unless state.is_a?(Hash)
          raise ArgumentError, "unknown state key on #{name}" if (state.keys - ["tracks"]).any?

          tracks = state["tracks"]
          raise ArgumentError, "state #{name} needs tracks" unless tracks.is_a?(Array) && tracks.any?

          copy[name] = {"tracks" => tracks.map { |track| sanitize_track(track, name, names) }}
        end
      end

      def sanitize_track(track, state_name, names)
        raise ArgumentError, "a track must be a Hash" unless track.is_a?(Hash)

        unknown = track.keys - TRACK_KEYS
        raise ArgumentError, "unknown track key: #{unknown.join(", ")}" if unknown.any?

        part = track["part"].to_s
        unless names.include?(part) || SPECIAL_PARTS.include?(part)
          raise ArgumentError, "unknown part #{part.inspect} in state #{state_name}"
        end

        property = track["property"].to_s
        raise ArgumentError, "unknown property #{property.inspect}" unless PROPERTIES.include?(property)

        {
          "part" => part,
          "property" => property,
          "keyframes" => sanitize_keyframes(track["keyframes"], property),
          "duration" => sanitize_duration(track["duration"]),
          "delay" => track.key?("delay") ? duration_number(track["delay"], "delay") : 0,
          "easing" => sanitize_easing(track["easing"] || "standard"),
          "iterations" => sanitize_iterations(track.key?("iterations") ? track["iterations"] : 1)
        }
      end

      def sanitize_keyframes(keyframes, property)
        raise ArgumentError, "keyframes must be an Array of at least two values" unless keyframes.is_a?(Array) && keyframes.size >= 2
        raise ArgumentError, "keyframes cannot have more than 32 values" if keyframes.size > 32

        keyframes.map { |entry| sanitize_keyframe(entry, property) }
      end

      def sanitize_keyframe(entry, property)
        return sanitize_keyframe_hash(entry, property) if entry.is_a?(Hash)

        sanitize_keyframe_value(entry, property)
      end

      def sanitize_keyframe_hash(entry, property)
        unknown = entry.keys - KEYFRAME_KEYS
        raise ArgumentError, "unknown keyframe key: #{unknown.join(", ")}" if unknown.any?

        sanitized = {"value" => sanitize_keyframe_value(entry["value"], property)}
        if entry.key?("offset")
          offset = number!(entry["offset"], "offset")
          raise ArgumentError, "offset must be between 0 and 1" unless offset.between?(0, 1)

          sanitized["offset"] = offset
        end
        sanitized
      end

      def sanitize_keyframe_value(value, property)
        return "length" if property == "strokeDashoffset" && value.to_s == "length"
        return unit_number(value, property) if property == "opacity"

        number!(value, property)
      end

      def sanitize_duration(value)
        return value.to_s if DURATION_TOKENS.include?(value.to_s)

        duration_number(value, "duration")
      end

      def sanitize_easing(value)
        easing = value.to_s
        return easing if EASINGS.include?(easing)

        raise ArgumentError, "easing must be one of: #{EASINGS.join(", ")}"
      end

      def sanitize_iterations(value)
        return "infinite" if value.to_s == "infinite"

        count = number!(value, "iterations")
        raise ArgumentError, "iterations must be a positive integer or infinite" unless count.is_a?(Integer) && count.positive?

        count
      end

      def duration_number(value, name)
        number = number!(value, name)
        raise ArgumentError, "#{name} must be zero or greater" if number.negative?
        raise ArgumentError, "#{name} is too long" if number > 60_000

        number
      end

      def unit_number(value, name)
        number = number!(value, name)
        raise ArgumentError, "#{name} must be between 0 and 1" unless number.between?(0, 1)

        number
      end

      def number!(value, name)
        number = Float(value)
        raise ArgumentError, "#{name} must be a number" unless number.finite?

        (number % 1).zero? ? number.to_i : number
      rescue ArgumentError, TypeError
        raise ArgumentError, "#{name} must be a number"
      end
    end
  end
end
