# frozen_string_literal: true

module FlatPack
  # Role to button style and size. A caller owns the map and draws the buttons.
  # Roles stay semantic. This module does not place items and does not name a layout.
  #
  # This is not FlatPack::PageNav, the back and close row.
  module PageNavRoleStyles
    # Solid primary, subtle secondary, danger. Small buttons.
    SOLID = {
      primary: {style: :primary, size: :sm}.freeze,
      secondary: {style: :secondary, size: :sm}.freeze,
      destructive: {style: :danger, size: :sm}.freeze
    }.freeze

    # Subtle primary, ghost secondary, danger. Small buttons.
    QUIET = {
      primary: {style: :secondary, size: :sm}.freeze,
      secondary: {style: :ghost, size: :sm}.freeze,
      destructive: {style: :danger, size: :sm}.freeze
    }.freeze

    # The pinned phone button. Solid primary, medium.
    PIN = {
      primary: {style: :primary, size: :md}.freeze
    }.freeze

    ENTRY_KEYS = %i[style size].freeze

    class << self
      def button_for(item, styles:, size: nil)
        raise ArgumentError, "a page nav component is rendered by the caller" if item.component?

        chosen = entry(styles, item.role)
        arguments = {
          text: item.label,
          href: item.href,
          style: chosen.fetch(:style),
          size: size || chosen.fetch(:size)
        }
        arguments[:icon] = item.icon if item.icon.present?
        arguments[:data] = item.data if item.data
        arguments[:aria] = item.aria if item.aria
        Button::Component.new(**arguments)
      end

      def entry(styles, role)
        normalize!(styles).fetch(normalize_role!(role)) do
          raise ArgumentError, "page nav styles need :#{normalize_role!(role)}"
        end
      end

      def normalize!(styles)
        raise ArgumentError, "page nav styles must be a Hash" unless styles.is_a?(Hash)

        styles.each_with_object({}) do |(role, entry), roles|
          roles[normalize_role!(role)] = normalize_entry!(entry)
        end.freeze
      end

      private

      def normalize_role!(role)
        name = role.to_sym if role.respond_to?(:to_sym)
        return name if PageNavItem::ROLES.include?(name)

        raise ArgumentError, "role must be :primary, :secondary, or :destructive"
      end

      def normalize_entry!(entry)
        raise ArgumentError, "page nav style entry must be a Hash" unless entry.is_a?(Hash)

        data = entry.each_with_object({}) { |(key, value), out| out[key.to_sym] = value }
        unknown = data.keys - ENTRY_KEYS
        raise ArgumentError, "unknown page nav style key: #{unknown.join(", ")}" if unknown.any?
        if (ENTRY_KEYS - data.keys).any?
          raise ArgumentError, "page nav style entry needs a style and a size"
        end

        style_name = data[:style].to_sym
        unless Button::StyleRegistry.known?(style_name)
          raise ArgumentError, Button::StyleRegistry.invalid_style_message(style_name)
        end

        size_name = data[:size].to_sym
        unless Button::Component::SIZES.key?(size_name)
          raise ArgumentError, "Invalid size: #{size_name}. Must be one of: #{Button::Component::SIZES.keys.join(", ")}"
        end

        {style: style_name, size: size_name}.freeze
      end
    end
  end
end
