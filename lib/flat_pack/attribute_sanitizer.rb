# frozen_string_literal: true

module FlatPack
  # AttributeSanitizer provides security utilities for sanitizing component attributes
  # to prevent XSS and injection attacks.
  class AttributeSanitizer
    # List of allowed URL protocols (whitelist approach)
    ALLOWED_PROTOCOLS = %w[http https mailto tel].freeze

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
        return nil if url.blank?

        # Convert to string in case we receive a symbol or other type
        url_string = url.to_s.strip

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

        # Check against whitelist of protocols
        protocol = url_string.split(":").first&.downcase
        return url_string if protocol && ALLOWED_PROTOCOLS.include?(protocol)

        # If no protocol is specified, treat as relative URL
        return url_string unless url_string.include?(":")

        # Otherwise, reject the URL
        nil
      end

      # Filters out dangerous HTML attributes from a hash of attributes
      # Returns a new hash with dangerous attributes removed
      #
      # @param attributes [Hash] Hash of HTML attributes
      # @return [Hash] Sanitized hash of attributes
      def sanitize_attributes(attributes)
        return {} if attributes.blank?

        attributes.reject do |key, _value|
          attribute_name = key.to_s.downcase
          DANGEROUS_ATTRIBUTES.include?(attribute_name)
        end
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
