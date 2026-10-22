# frozen_string_literal: true

module FlatPack
  # Maps a page-action role to a button style and size for one context.
  # Layouts decide where the buttons go.
  module PageActions
    CONTEXTS = %i[header top_nav].freeze

    # Concrete Button `style:` tokens. A layout overrides a role with `styles:`.
    STYLES = {
      header: {primary: :primary, secondary: :secondary, destructive: :danger}.freeze,
      top_nav: {primary: :secondary, secondary: :ghost, destructive: :danger}.freeze
    }.freeze

    SIZES = {
      header: :sm,
      top_nav: :sm
    }.freeze

    class << self
      def styles(context, overrides = nil, **keywords)
        map = STYLES.fetch(normalize_context!(context)).dup
        apply_overrides!(map, overrides)
        apply_overrides!(map, keywords)
        map
      end

      def size(context)
        SIZES.fetch(normalize_context!(context))
      end

      private

      def normalize_context!(context)
        name = context.to_sym
        return name if CONTEXTS.include?(name)

        raise ArgumentError, "context must be :header or :top_nav"
      end

      def apply_overrides!(map, overrides)
        return map if overrides.blank?

        overrides.each do |role, style|
          role_name = role.to_sym
          unless PageAction::ROLES.include?(role_name)
            raise ArgumentError, "role must be :primary, :secondary, or :destructive"
          end

          style_name = style.to_sym
          unless Button::StyleRegistry.known?(style_name)
            raise ArgumentError, Button::StyleRegistry.invalid_style_message(style_name)
          end

          map[role_name] = style_name
        end

        map
      end
    end
  end
end
