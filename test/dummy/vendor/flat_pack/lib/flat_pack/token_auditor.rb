# frozen_string_literal: true

require "pathname"

module FlatPack
  # Ensures every CSS custom property referenced in the gem is defined in variables.css.
  # RUNTIME_TOKENS are set by a component or by kit CSS, not by the theme file.
  class TokenAuditor
    REFERENCE_PATTERN = /
      var\(\s*(--[A-Za-z0-9-]+)
      |
      (?:bg|text|border|ring|fill|stroke|from|to|via|accent|caret|outline|shadow|decoration)-\(\s*(--[A-Za-z0-9-]+)\s*\)
    /x

    RUNTIME_TOKENS = %w[
      --collection-editor-columns
      --flat-pack-surface-fill
      --flatpack-modal-body-height
      --flatpack-picker-items-height
      --fp-masonry-gap
      --fp-masonry-row
      --fp-collage-columns
      --fp-collage-scatter
      --fp-collage-shift-x
      --fp-collage-shift-y
      --fp-collage-tilt
      --fp-collage-x
      --fp-collage-y
      --fp-collage-angle
      --fp-collage-index
      --fp-collage-z
      --fp-collage-scale
      --fp-collage-column
      --fp-collage-row
      --fp-collage-tracks
      --fp-collage-row-shift
      --fp-collage-place-x
      --fp-collage-place-y
      --fp-collage-center-x
      --fp-collage-center-y
      --fp-collage-count
      --reveal-index
      --reveal-delay
      --reveal-duration
      --fp-number-duration
      --fp-collage-mobile
      --fp-collage-from-x
      --fp-collage-from-y
      --fp-trash-button-size
      --fp-collection-min-item-width
      --fp-fab-offset
      --fp-fab-nav-offset
      --fp-primary-hover-fill
      --fp-primary-pressed-fill
      --fp-list-key-width
      --fp-range-max
      --fp-range-scale
      --fp-range-value
      --range-progress
      --sidebar-measured-width
      --sidebar-collapsed-frame
      --fp-panel-width
      --page-layout-width
      --read-more-lines
      --spacing
      --carousel-bleed
      --card-inset
      --card-inner-radius
      --card-title-size
      --card-title-weight
      --card-title-color
      --card-media-image-height
      --fp-overlay-item-inset
      --overlay-inset-sm
      --overlay-inset-md
      --overlay-inset-lg
      --dropdown-max-height
      --fp-pane-fade-top
      --fp-pane-fade-bottom
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
      referenced = referenced_tokens - RUNTIME_TOKENS
      missing = (referenced - defined).sort

      Result.new(defined: defined, referenced: referenced, missing: missing)
    end

    private

    attr_reader :engine_root

    def defined_tokens
      css = engine_root.join("app/assets/stylesheets/flat_pack/variables.css").read
      css.scan(/--[A-Za-z0-9-]+(?=\s*:)/).uniq
    end

    def referenced_tokens
      tokens = []

      scan_globs.each do |path|
        next if path.to_s.end_with?("flat_pack/variables.css")

        path.read.scan(REFERENCE_PATTERN) do |var_match, utility_match|
          token = var_match || utility_match
          next if token.end_with?("-")
          next if token.include?("*")

          tokens << token
        end
      end

      tokens.uniq
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
