# frozen_string_literal: true

module FlatPack
  module Card
    # Colour fill for a card. Shadow, border, and hover stay separate.
    module Style
      NAMES = %i[default shaded brand brand_subtle gradient].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "[background:var(--card-style-default-background)]" "[--surface-content-color:var(--card-style-default-text-color)]" "[--surface-muted-content-color:var(--card-style-default-muted-text-color)]" "[--surface-border-color:var(--card-style-default-border-color)]" "[--card-border-color:var(--card-style-default-border-color)]"
      # "[background:var(--card-style-shaded-background)]" "[--surface-content-color:var(--card-style-shaded-text-color)]" "[--surface-muted-content-color:var(--card-style-shaded-muted-text-color)]" "[--surface-border-color:var(--card-style-shaded-border-color)]" "[--card-border-color:var(--card-style-shaded-border-color)]"
      # "[background:var(--card-style-brand-background)]" "[--surface-content-color:var(--card-style-brand-text-color)]" "[--surface-muted-content-color:var(--card-style-brand-muted-text-color)]" "[--surface-border-color:var(--card-style-brand-border-color)]" "[--card-border-color:var(--card-style-brand-border-color)]"
      # "[background:var(--card-style-brand-subtle-background)]" "[--surface-content-color:var(--card-style-brand-subtle-text-color)]" "[--surface-muted-content-color:var(--card-style-brand-subtle-muted-text-color)]" "[--surface-border-color:var(--card-style-brand-subtle-border-color)]" "[--card-border-color:var(--card-style-brand-subtle-border-color)]"
      # "[background:var(--card-style-gradient-background)]" "[--surface-content-color:var(--card-style-gradient-text-color)]" "[--surface-muted-content-color:var(--card-style-gradient-muted-text-color)]" "[--surface-border-color:var(--card-style-gradient-border-color)]" "[--card-border-color:var(--card-style-gradient-border-color)]"
      CLASSES = {
        default: [
          "[background:var(--card-style-default-background)]",
          "[--surface-content-color:var(--card-style-default-text-color)]",
          "[--surface-muted-content-color:var(--card-style-default-muted-text-color)]",
          "[--surface-border-color:var(--card-style-default-border-color)]",
          "[--card-border-color:var(--card-style-default-border-color)]"
        ].join(" "),
        shaded: [
          "[background:var(--card-style-shaded-background)]",
          "[--surface-content-color:var(--card-style-shaded-text-color)]",
          "[--surface-muted-content-color:var(--card-style-shaded-muted-text-color)]",
          "[--surface-border-color:var(--card-style-shaded-border-color)]",
          "[--card-border-color:var(--card-style-shaded-border-color)]"
        ].join(" "),
        brand: [
          "[background:var(--card-style-brand-background)]",
          "[--surface-content-color:var(--card-style-brand-text-color)]",
          "[--surface-muted-content-color:var(--card-style-brand-muted-text-color)]",
          "[--surface-border-color:var(--card-style-brand-border-color)]",
          "[--card-border-color:var(--card-style-brand-border-color)]"
        ].join(" "),
        brand_subtle: [
          "[background:var(--card-style-brand-subtle-background)]",
          "[--surface-content-color:var(--card-style-brand-subtle-text-color)]",
          "[--surface-muted-content-color:var(--card-style-brand-subtle-muted-text-color)]",
          "[--surface-border-color:var(--card-style-brand-subtle-border-color)]",
          "[--card-border-color:var(--card-style-brand-subtle-border-color)]"
        ].join(" "),
        gradient: [
          "[background:var(--card-style-gradient-background)]",
          "[--surface-content-color:var(--card-style-gradient-text-color)]",
          "[--surface-muted-content-color:var(--card-style-gradient-muted-text-color)]",
          "[--surface-border-color:var(--card-style-gradient-border-color)]",
          "[--card-border-color:var(--card-style-gradient-border-color)]"
        ].join(" ")
      }.freeze

      def self.classes_for(style)
        key = style.to_sym
        CLASSES.fetch(key)
      rescue NoMethodError, KeyError
        raise ArgumentError, "Invalid style: #{style.inspect}. Must be one of: #{NAMES.join(", ")}"
      end
    end
  end
end
