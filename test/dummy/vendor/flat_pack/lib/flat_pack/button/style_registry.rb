# frozen_string_literal: true

module FlatPack
  module Button
    # Built-in and host-registered button colourways.
    # Colour paint lives in kit CSS on `.fp-button[data-fp-style]`.
    # A host or gem registers a name here, then ships CSS for that attribute.
    module StyleRegistry
      PRESS_VALUES = %i[raised flat].freeze

      BUILT_IN = {
        default: {press: :raised},
        primary: {press: :raised},
        secondary: {press: :flat},
        ghost: {press: :flat},
        success: {press: :raised},
        warning: {press: :raised},
        danger: {press: :raised}
      }.freeze

      NAME_PATTERN = /\A[a-z][a-z0-9_]*\z/

      class << self
        def register(name, press: :raised)
          style_name = normalize_name(name)
          press_name = press.to_sym

          if BUILT_IN.key?(style_name)
            raise ArgumentError, "Cannot replace built-in button style: #{style_name}"
          end

          unless PRESS_VALUES.include?(press_name)
            raise ArgumentError, "Invalid press: #{press}. Must be one of: #{PRESS_VALUES.join(", ")}"
          end

          unless style_name.match?(NAME_PATTERN)
            raise ArgumentError, "Invalid style name: #{name}. Use a lowercase letter, then letters, numbers, or underscores."
          end

          extra_styles[style_name] = {press: press_name}
          style_name
        end

        def unregister(name)
          extra_styles.delete(normalize_name(name))
        end

        def reset!
          extra_styles.clear
        end

        def known?(name)
          all.key?(normalize_name(name))
        end

        def names
          all.keys
        end

        def press_for(name)
          style_name = normalize_name(name)
          config = all[style_name]
          raise ArgumentError, invalid_style_message(style_name) if config.nil?

          config.fetch(:press)
        end

        def press_class(name)
          (press_for(name) == :flat) ? "fp-button-flat" : "fp-button-raised"
        end

        def all
          BUILT_IN.merge(extra_styles)
        end

        def extra_styles
          @extra_styles ||= {}
        end

        def invalid_style_message(name)
          "Invalid style: #{name}. Must be one of: #{names.join(", ")}"
        end

        private

        def normalize_name(name)
          name.to_sym
        end
      end
    end

    def self.register_style(name, press: :raised)
      StyleRegistry.register(name, press: press)
    end

    def self.unregister_style(name)
      StyleRegistry.unregister(name)
    end

    def self.styles
      StyleRegistry.names
    end
  end
end
