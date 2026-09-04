# frozen_string_literal: true

module FlatPack
  # AttributeSanitizer provides security utilities for sanitizing component attributes
  # to prevent XSS and injection attacks.
  class AttributeSanitizer
    # List of allowed URL protocols (whitelist approach)
    ALLOWED_PROTOCOLS = %w[http https mailto tel].freeze

    CSS_COLOR_KEYWORDS = %w[
      transparent currentcolor inherit initial unset revert revert-layer
    ].freeze

    CSS_COLOR_FUNCTION_PATTERN = /\A(?:rgb|rgba|hsl|hsla|oklab|oklch|lab|lch|color)\([a-z0-9\s.,%+\-\/#]+\)\z/i
    CSS_COLOR_VAR_PATTERN = /\Avar\(--[a-z0-9-]+\)\z/i
    CSS_HEX_COLOR_PATTERN = /\A#(?:[\da-f]{3}|[\da-f]{4}|[\da-f]{6}|[\da-f]{8})\z/i

    # Safe CSS font-family values for style interpolation (no url()/expression/; injection).
    CSS_FONT_FAMILY_TOKEN = /
      (?:
        var\(--[a-z0-9-]+\)
        |
        "[a-z0-9][a-z0-9\s._-]*"
        |
        '[a-z0-9][a-z0-9\s._-]*'
        |
        [a-z0-9][a-z0-9_-]*
      )
    /ix
    CSS_FONT_FAMILY_PATTERN = /\A#{CSS_FONT_FAMILY_TOKEN.source}(?:\s*,\s*#{CSS_FONT_FAMILY_TOKEN.source})*\z/ix

    # Safe CSS grid track values for style interpolation, so a caller can size a
    # column without opening the style attribute to arbitrary declarations.
    CSS_GRID_TRACK_LENGTH = /
      (?:
        [+-]?\d+(?:\.\d+)?(?:px|rem|em|ch|ex|vw|vh|vmin|vmax|%|fr)?
        |
        auto|min-content|max-content
        |
        var\(--[a-z0-9-]+\)
      )
    /ix
    CSS_GRID_TRACK_PATTERN = /
      \A
      (?:
        #{CSS_GRID_TRACK_LENGTH.source}
        |
        minmax\(\s*#{CSS_GRID_TRACK_LENGTH.source}\s*,\s*#{CSS_GRID_TRACK_LENGTH.source}\s*\)
        |
        clamp\(\s*#{CSS_GRID_TRACK_LENGTH.source}\s*,\s*#{CSS_GRID_TRACK_LENGTH.source}\s*,\s*#{CSS_GRID_TRACK_LENGTH.source}\s*\)
        |
        fit-content\(\s*#{CSS_GRID_TRACK_LENGTH.source}\s*\)
      )
      \z
    /ix

    # List of dangerous HTML attributes that should be filtered out
    DANGEROUS_ATTRIBUTES = %w[
      onclick onload onerror onmouseover onmouseout onmousemove
      onmouseenter onmouseleave onfocus onblur onchange onsubmit
      onkeydown onkeyup onkeypress ondblclick oncontextmenu
      onwheel ondrag ondrop onscroll oncopy oncut onpaste
    ].freeze

    class << self
      # Validates a URL to ensure it uses a safe protocol
      # Returns the URL if safe, nil otherwise
      #
      # @param url [String] The URL to validate
      # @return [String, nil] The URL if valid, nil if invalid
      def sanitize_url(url)
        return nil if url.nil? || url.to_s.strip.empty?

        # Convert to string in case we receive a symbol or other type
        url_string = url.to_s.strip

        # Block URLs with HTML entity encoding that could be used to hide dangerous protocols
        # Specifically target colon entities: &colon;, &#58; (decimal), &#x3a; (hex)
        return nil if url_string.match?(/&(?:colon|#(?:0*58|x0*3a));/i)

        # Block javascript: protocol entirely
        return nil if url_string.match?(/^\s*javascript:/i)

        # Block data: URLs that could contain scripts
        return nil if url_string.match?(/^\s*data:/i)

        # Block vbscript: protocol
        return nil if url_string.match?(/^\s*vbscript:/i)

        # Check if URL starts with an allowed protocol
        # Also allow relative URLs (starting with / or .)
        # and fragment identifiers (starting with #)
        return url_string if url_string.start_with?("/", ".", "#")

        # Extract protocol more robustly using regex to handle edge cases
        # Match protocol at the start of the string, followed by : (with optional //)
        # mailto: and tel: don't use //, but http: and https: do
        protocol_match = url_string.match(/\A([a-z][a-z0-9+.-]*):/i)
        if protocol_match
          protocol = protocol_match[1].downcase
          return url_string if ALLOWED_PROTOCOLS.include?(protocol)
          # Protocol found but not in whitelist
          return nil
        end

        # If no protocol is specified, treat as relative URL
        # But reject if it contains : (could be malformed protocol)
        return url_string unless url_string.include?(":")

        # Contains : but no valid protocol pattern - reject
        nil
      end

      # Filters out dangerous HTML attributes from a hash of attributes
      # Returns a new hash with dangerous attributes removed
      #
      # @param attributes [Hash] Hash of HTML attributes
      # @return [Hash] Sanitized hash of attributes
      def sanitize_attributes(attributes)
        return {} if attributes.nil? || attributes.empty?

        attributes.reject do |key, _value|
          attribute_name = key.to_s.downcase
          DANGEROUS_ATTRIBUTES.include?(attribute_name)
        end
      end

      # Validates CSS color values that are safe to interpolate into a style
      # attribute as custom property values.
      #
      # @param value [String] The CSS color token to validate
      # @return [String, nil] The sanitized color value if valid, nil otherwise
      def sanitize_css_color(value)
        return nil if value.nil?

        color = value.to_s.strip
        return nil if color.empty?

        return color if CSS_HEX_COLOR_PATTERN.match?(color)
        return color if CSS_COLOR_VAR_PATTERN.match?(color)
        return color if CSS_COLOR_FUNCTION_PATTERN.match?(color)
        return color if CSS_COLOR_KEYWORDS.include?(color.downcase)

        nil
      end

      # Validates CSS font-family values that are safe to interpolate into a style
      # attribute. Accepts generic families, unquoted/quoted family names, CSS
      # variables, and comma-separated stacks.
      #
      # @param value [String] The CSS font-family token to validate
      # @return [String, nil] The sanitized font-family value if valid, nil otherwise
      def sanitize_css_font_family(value)
        return nil if value.nil?

        font = value.to_s.strip
        return nil if font.empty?

        return font if CSS_FONT_FAMILY_PATTERN.match?(font)

        nil
      end

      # Validates a single CSS grid track that is safe to interpolate into a
      # style attribute. Accepts lengths, keywords, CSS variables, and the
      # minmax/clamp/fit-content sizing functions.
      #
      # @param value [String] The CSS grid track to validate
      # @return [String, nil] The sanitized track if valid, nil otherwise
      def sanitize_css_grid_track(value)
        return nil if value.nil?

        track = value.to_s.strip
        return nil if track.empty?

        return track if CSS_GRID_TRACK_PATTERN.match?(track)

        nil
      end

      # Validates and sanitizes a href attribute specifically
      # Raises an error if the URL is unsafe
      #
      # @param href [String] The href value to validate
      # @return [String] The sanitized href
      # @raise [ArgumentError] if the href is unsafe
      def validate_href!(href)
        sanitized = sanitize_url(href)
        if sanitized.nil?
          raise ArgumentError, "Unsafe URL detected: #{href}. Only http, https, mailto, tel protocols and relative URLs are allowed."
        end
        sanitized
      end
    end
  end
end
