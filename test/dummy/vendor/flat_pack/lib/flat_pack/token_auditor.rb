# frozen_string_literal: true

require "pathname"
require "set"

module FlatPack
  # Ensures every CSS custom property referenced in the gem is defined in variables.css.
  class TokenAuditor
    REFERENCE_PATTERN = /
      var\(\s*(--[A-Za-z0-9-]+)
      |
      (?:bg|text|border|ring|fill|stroke|from|to|via|accent|caret|outline|shadow|decoration)-\(\s*(--[A-Za-z0-9-]+)\s*\)
    /x

    RUNTIME_TOKENS = %w[
      --flatpack-modal-body-height
      --flatpack-picker-items-height
      --spacing
    ].freeze

    Result = Struct.new(:defined, :referenced, :missing, keyword_init: true) do
      def success?
        missing.empty?
      end
    end

    def initialize(engine_root: FlatPack::Engine.root)
      @engine_root = Pathname.new(engine_root)
    end

    def call
      defined = defined_tokens
      referenced = referenced_tokens - RUNTIME_TOKENS.to_set
      missing = (referenced - defined).sort

      Result.new(defined: defined, referenced: referenced, missing: missing)
    end

    private

    attr_reader :engine_root

    def defined_tokens
      css = engine_root.join("app/assets/stylesheets/flat_pack/variables.css").read
      css.scan(/--[A-Za-z0-9-]+(?=\s*:)/).to_set
    end

    def referenced_tokens
      tokens = Set.new

      scan_globs.each do |path|
        path.read.scan(REFERENCE_PATTERN) do |var_match, utility_match|
          tokens << (var_match || utility_match)
        end
      end

      tokens
    end

    def scan_globs
      patterns = [
        "app/components/**/*.{rb,erb}",
        "app/javascript/**/*.{js,ts}",
        "app/assets/stylesheets/**/*.css"
      ]

      patterns.flat_map { |pattern| Dir[engine_root.join(pattern)].map { |path| Pathname.new(path) } }
    end
  end
end
