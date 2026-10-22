# frozen_string_literal: true

module FlatPack
  # Role to button style and size. Layouts and hosts own the map.
  # A gem emits a role. It does not write the map.
  #
  # Resolution for one context is the map passed to `render_page_nav`, then
  # `FlatPack.configuration.page_nav_styles`, then `DEFAULT_STYLES`.
  module PageNav
    CONTEXTS = %i[header top_nav].freeze

    DEFAULT_STYLES = {
      header: {
        primary: {style: :primary, size: :sm}.freeze,
        secondary: {style: :secondary, size: :sm}.freeze,
        destructive: {style: :danger, size: :sm}.freeze
      }.freeze,
      top_nav: {
        primary: {style: :secondary, size: :sm}.freeze,
        secondary: {style: :ghost, size: :sm}.freeze,
        destructive: {style: :danger, size: :sm}.freeze
      }.freeze
    }.freeze

    class << self
      def resolve(context, override = nil)
        name = normalize_context!(context)
        merged = merge_styles(DEFAULT_STYLES, FlatPack.configuration.page_nav_styles, normalize_styles!(override))
        merged.fetch(name)
      end

      def normalize_styles!(map)
        return if map.nil?
        raise ArgumentError, "page nav styles must be a Hash" unless map.is_a?(Hash)

        map.each_with_object({}) do |(context, roles), contexts|
          context_name = normalize_context!(context)
          raise ArgumentError, "page nav styles for #{context_name} must be a Hash" unless roles.is_a?(Hash)

          contexts[context_name] = roles.each_with_object({}) do |(role, entry), roles_out|
            roles_out[normalize_role!(role)] = normalize_entry!(entry)
          end.freeze
        end.freeze
      end

      private

      def merge_styles(*maps)
        result = {}
        maps.compact.each do |map|
          map.each do |context, roles|
            bucket = (result[context.to_sym] ||= {})
            roles.each do |role, entry|
              current = bucket[role.to_sym] || {}
              bucket[role.to_sym] = current.merge(entry)
            end
          end
        end
        result
      end

      def normalize_context!(context)
        name = context.to_sym if context.respond_to?(:to_sym)
        return name if CONTEXTS.include?(name)

        raise ArgumentError, "context must be :header or :top_nav"
      end

      def normalize_role!(role)
        name = role.to_sym if role.respond_to?(:to_sym)
        return name if PageNavItem::ROLES.include?(name)

        raise ArgumentError, "role must be :primary, :secondary, or :destructive"
      end

      def normalize_entry!(entry)
        raise ArgumentError, "page nav style entry must be a Hash" unless entry.is_a?(Hash)

        data = entry.each_with_object({}) { |(key, value), out| out[key.to_sym] = value }
        unknown = data.keys - %i[style size]
        raise ArgumentError, "unknown page nav style key: #{unknown.join(", ")}" if unknown.any?
        raise ArgumentError, "page nav style entry needs a style or a size" if data.empty?

        normalized = {}
        if data.key?(:style)
          style_name = data[:style].to_sym
          unless Button::StyleRegistry.known?(style_name)
            raise ArgumentError, Button::StyleRegistry.invalid_style_message(style_name)
          end

          normalized[:style] = style_name
        end
        if data.key?(:size)
          size_name = data[:size].to_sym
          unless Button::Component::SIZES.key?(size_name)
            raise ArgumentError, "Invalid size: #{size_name}. Must be one of: #{Button::Component::SIZES.keys.join(", ")}"
          end

          normalized[:size] = size_name
        end
        normalized.freeze
      end
    end
  end
end
