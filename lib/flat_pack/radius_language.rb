# frozen_string_literal: true

module FlatPack
  module RadiusLanguage
    SCALE = {
      "sm" => "--radius-sm",
      "md" => "--radius-md",
      "lg" => "--radius-lg",
      "xl" => "--radius-xl",
      "2xl" => "--radius-md",
      "3xl" => "--radius-lg"
    }.freeze

    SIDES = %w[ss se ee es tl tr bl br t b l r s e].freeze

    SCALE_ALTERNATION = SCALE.keys.sort_by { |key| -key.length }.map { |key| Regexp.escape(key) }.join("|")
    SIDE_ALTERNATION = SIDES.map { |side| Regexp.escape(side) }.join("|")

    UTILITY_PATTERN = /
      (?<![A-Za-z0-9_-])
      rounded
      (?:-(?:#{SIDE_ALTERNATION}))?
      -(?:#{SCALE_ALTERNATION})
      (?![A-Za-z0-9_-])
    /x

    CSS_FALLBACKS = {
      "var(--radius-md, 0.375rem)" => "var(--radius-md, 1rem)",
      "var(--radius-sm, 0.25rem)" => "var(--radius-sm, 0.75rem)"
    }.freeze

    module_function

    def rewrite(source)
      rewritten = source.gsub(UTILITY_PATTERN) { |match| replace_utility(match) }
      CSS_FALLBACKS.reduce(rewritten) { |text, (from, to)| text.gsub(from, to) }
    end

    def utilities_in(source)
      source.scan(UTILITY_PATTERN)
    end

    def replace_utility(match)
      rest = match.sub(/\Arounded-/, "")
      scale = SCALE.keys.sort_by { |key| -key.length }.find { |key| rest == key || rest.end_with?("-#{key}") }
      token = SCALE.fetch(scale)
      prefix = rest.delete_suffix(scale)
      "rounded-#{prefix}[var(#{token})]"
    end
  end
end
