# frozen_string_literal: true

require "pathname"
require "flat_pack/radius_language"

module FlatPack
  # Fails when kit Ruby/JS still uses Tailwind radius scale utilities
  # (rounded-md, rounded-lg, …) instead of rounded-[var(--radius-*)].
  class RadiusLanguageAuditor
    SCAN_GLOBS = [
      "app/components/**/*.{rb,erb}",
      "app/javascript/**/*.{js,ts}"
    ].freeze

    Violation = Struct.new(:path, :utilities, keyword_init: true)
    Result = Struct.new(:violations, keyword_init: true) do
      def success?
        violations.empty?
      end
    end

    def initialize(engine_root: FlatPack::Engine.root)
      @engine_root = Pathname.new(engine_root)
    end

    def call
      violations = scan_paths.filter_map do |path|
        utilities = RadiusLanguage.utilities_in(path.read)
        next if utilities.empty?

        Violation.new(path: path.to_s, utilities: utilities.uniq)
      end

      Result.new(violations: violations)
    end

    private

    attr_reader :engine_root

    def scan_paths
      SCAN_GLOBS.flat_map { |pattern| Dir[engine_root.join(pattern)].map { |path| Pathname.new(path) } }
    end
  end
end
