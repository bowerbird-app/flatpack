# frozen_string_literal: true

require "flat_pack/version"
require "flat_pack/engine"

module FlatPack
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :default_theme

    def initialize
      @default_theme = :light
    end
  end
end
