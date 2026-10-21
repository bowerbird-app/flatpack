# frozen_string_literal: true

module FlatPack
  module Card
    # Colour fill for a card. Shadow, border, and hover stay separate.
    module Background
      NAMES = %i[default none shaded brand brand_subtle gradient].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "[background:var(--card-background-default)]" "[--surface-content-color:var(--card-background-default-text-color)]" "[--surface-muted-content-color:var(--card-background-default-muted-text-color)]" "[--surface-border-color:var(--card-background-default-border-color)]" "[--card-border-color:var(--card-background-default-border-color)]"
      # "[background:var(--card-background-none)]"
      # "[background:var(--card-background-shaded)]" "[--surface-content-color:var(--card-background-shaded-text-color)]" "[--surface-muted-content-color:var(--card-background-shaded-muted-text-color)]" "[--surface-border-color:var(--card-background-shaded-border-color)]" "[--card-border-color:var(--card-background-shaded-border-color)]"
      # "[background:var(--card-background-brand)]" "[--surface-content-color:var(--card-background-brand-text-color)]" "[--surface-muted-content-color:var(--card-background-brand-muted-text-color)]" "[--surface-border-color:var(--card-background-brand-border-color)]" "[--card-border-color:var(--card-background-brand-border-color)]"
      # "[background:var(--card-background-brand-subtle)]" "[--surface-content-color:var(--card-background-brand-subtle-text-color)]" "[--surface-muted-content-color:var(--card-background-brand-subtle-muted-text-color)]" "[--surface-border-color:var(--card-background-brand-subtle-border-color)]" "[--card-border-color:var(--card-background-brand-subtle-border-color)]"
      # "[background:var(--card-background-gradient)]" "[--surface-content-color:var(--card-background-gradient-text-color)]" "[--surface-muted-content-color:var(--card-background-gradient-muted-text-color)]" "[--surface-border-color:var(--card-background-gradient-border-color)]" "[--card-border-color:var(--card-background-gradient-border-color)]"
      CLASSES = {
        default: [
          "[background:var(--card-background-default)]",
          "[--surface-content-color:var(--card-background-default-text-color)]",
          "[--surface-muted-content-color:var(--card-background-default-muted-text-color)]",
          "[--surface-border-color:var(--card-background-default-border-color)]",
          "[--card-border-color:var(--card-background-default-border-color)]"
        ].join(" "),
        none: "[background:var(--card-background-none)]",
        shaded: [
          "[background:var(--card-background-shaded)]",
          "[--surface-content-color:var(--card-background-shaded-text-color)]",
          "[--surface-muted-content-color:var(--card-background-shaded-muted-text-color)]",
          "[--surface-border-color:var(--card-background-shaded-border-color)]",
          "[--card-border-color:var(--card-background-shaded-border-color)]"
        ].join(" "),
        brand: [
          "[background:var(--card-background-brand)]",
          "[--surface-content-color:var(--card-background-brand-text-color)]",
          "[--surface-muted-content-color:var(--card-background-brand-muted-text-color)]",
          "[--surface-border-color:var(--card-background-brand-border-color)]",
          "[--card-border-color:var(--card-background-brand-border-color)]"
        ].join(" "),
        brand_subtle: [
          "[background:var(--card-background-brand-subtle)]",
          "[--surface-content-color:var(--card-background-brand-subtle-text-color)]",
          "[--surface-muted-content-color:var(--card-background-brand-subtle-muted-text-color)]",
          "[--surface-border-color:var(--card-background-brand-subtle-border-color)]",
          "[--card-border-color:var(--card-background-brand-subtle-border-color)]"
        ].join(" "),
        gradient: [
          "[background:var(--card-background-gradient)]",
          "[--surface-content-color:var(--card-background-gradient-text-color)]",
          "[--surface-muted-content-color:var(--card-background-gradient-muted-text-color)]",
          "[--surface-border-color:var(--card-background-gradient-border-color)]",
          "[--card-border-color:var(--card-background-gradient-border-color)]"
        ].join(" ")
      }.freeze

      def self.classes_for(background)
        key = background.to_sym
        CLASSES.fetch(key)
      rescue NoMethodError, KeyError
        raise ArgumentError, "Invalid background: #{background.inspect}. Must be one of: #{NAMES.join(", ")}"
      end
    end
  end
end
