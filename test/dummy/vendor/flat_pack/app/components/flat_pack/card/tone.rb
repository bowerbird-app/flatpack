# frozen_string_literal: true

module FlatPack
  module Card
    # Colour fill for a card. Style stays structural (border, shadow, hover).
    module Tone
      NAMES = %i[default shaded brand brand_subtle gradient].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "[background:var(--card-tone-default-background)]" "[--surface-content-color:var(--card-tone-default-text-color)]" "[--surface-muted-content-color:var(--card-tone-default-muted-text-color)]" "[--surface-border-color:var(--card-tone-default-border-color)]" "[--card-border-color:var(--card-tone-default-border-color)]"
      # "[background:var(--card-tone-shaded-background)]" "[--surface-content-color:var(--card-tone-shaded-text-color)]" "[--surface-muted-content-color:var(--card-tone-shaded-muted-text-color)]" "[--surface-border-color:var(--card-tone-shaded-border-color)]" "[--card-border-color:var(--card-tone-shaded-border-color)]"
      # "[background:var(--card-tone-brand-background)]" "[--surface-content-color:var(--card-tone-brand-text-color)]" "[--surface-muted-content-color:var(--card-tone-brand-muted-text-color)]" "[--surface-border-color:var(--card-tone-brand-border-color)]" "[--card-border-color:var(--card-tone-brand-border-color)]"
      # "[background:var(--card-tone-brand-subtle-background)]" "[--surface-content-color:var(--card-tone-brand-subtle-text-color)]" "[--surface-muted-content-color:var(--card-tone-brand-subtle-muted-text-color)]" "[--surface-border-color:var(--card-tone-brand-subtle-border-color)]" "[--card-border-color:var(--card-tone-brand-subtle-border-color)]"
      # "[background:var(--card-tone-gradient-background)]" "[--surface-content-color:var(--card-tone-gradient-text-color)]" "[--surface-muted-content-color:var(--card-tone-gradient-muted-text-color)]" "[--surface-border-color:var(--card-tone-gradient-border-color)]" "[--card-border-color:var(--card-tone-gradient-border-color)]"
      CLASSES = {
        default: [
          "[background:var(--card-tone-default-background)]",
          "[--surface-content-color:var(--card-tone-default-text-color)]",
          "[--surface-muted-content-color:var(--card-tone-default-muted-text-color)]",
          "[--surface-border-color:var(--card-tone-default-border-color)]",
          "[--card-border-color:var(--card-tone-default-border-color)]"
        ].join(" "),
        shaded: [
          "[background:var(--card-tone-shaded-background)]",
          "[--surface-content-color:var(--card-tone-shaded-text-color)]",
          "[--surface-muted-content-color:var(--card-tone-shaded-muted-text-color)]",
          "[--surface-border-color:var(--card-tone-shaded-border-color)]",
          "[--card-border-color:var(--card-tone-shaded-border-color)]"
        ].join(" "),
        brand: [
          "[background:var(--card-tone-brand-background)]",
          "[--surface-content-color:var(--card-tone-brand-text-color)]",
          "[--surface-muted-content-color:var(--card-tone-brand-muted-text-color)]",
          "[--surface-border-color:var(--card-tone-brand-border-color)]",
          "[--card-border-color:var(--card-tone-brand-border-color)]"
        ].join(" "),
        brand_subtle: [
          "[background:var(--card-tone-brand-subtle-background)]",
          "[--surface-content-color:var(--card-tone-brand-subtle-text-color)]",
          "[--surface-muted-content-color:var(--card-tone-brand-subtle-muted-text-color)]",
          "[--surface-border-color:var(--card-tone-brand-subtle-border-color)]",
          "[--card-border-color:var(--card-tone-brand-subtle-border-color)]"
        ].join(" "),
        gradient: [
          "[background:var(--card-tone-gradient-background)]",
          "[--surface-content-color:var(--card-tone-gradient-text-color)]",
          "[--surface-muted-content-color:var(--card-tone-gradient-muted-text-color)]",
          "[--surface-border-color:var(--card-tone-gradient-border-color)]",
          "[--card-border-color:var(--card-tone-gradient-border-color)]"
        ].join(" ")
      }.freeze

      def self.classes_for(tone)
        key = tone.to_sym
        CLASSES.fetch(key)
      rescue NoMethodError, KeyError
        raise ArgumentError, "Invalid tone: #{tone.inspect}. Must be one of: #{NAMES.join(", ")}"
      end

      def self.contrast?(tone)
        %i[brand gradient].include?(tone.to_sym)
      end
    end
  end
end
