# frozen_string_literal: true

require "flat_pack/version"
require "flat_pack/engine"
require "flat_pack/attribute_sanitizer"
require "flat_pack/rich_text_sanitizer"

module FlatPack
  HEROICON_VARIANTS = %i[outline solid mini micro].freeze

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :default_theme
    attr_reader :default_icon_variant

    def initialize
      @default_theme = :light
      @default_icon_variant = :outline
    end

    def default_icon_variant=(variant)
      normalized_variant = variant.to_sym

      if FlatPack::HEROICON_VARIANTS.include?(normalized_variant)
        @default_icon_variant = normalized_variant
        return
      end

      raise ArgumentError, "Invalid heroicon variant: #{variant}. Must be one of: #{FlatPack::HEROICON_VARIANTS.join(", ")}"
    end
  end
end
