# frozen_string_literal: true

module FlatPack
  module Kbd
    class Component < FlatPack::BaseComponent
      def initialize(keys:, **system_arguments)
        super(**system_arguments)
        @keys = Array(keys).map { |key| key.to_s.strip }.reject(&:blank?)
        validate_keys!
      end

      def call
        content_tag(:span, class: group_classes) do
          safe_join(keycaps)
        end
      end

      private

      def keycaps
        @keys.each_with_index.flat_map do |key, index|
          parts = []
          parts << content_tag(:span, "+", class: "text-[var(--kbd-muted-color)]", "aria-hidden": "true") if index.positive?
          parts << content_tag(:kbd, key, class: keycap_classes)
          parts
        end
      end

      def group_classes
        classes("inline-flex items-center gap-1")
      end

      def keycap_classes
        [
          "inline-flex items-center justify-center",
          "min-w-[1.5rem] px-1.5 py-0.5",
          "rounded-[var(--radius-sm)]",
          "border border-[var(--kbd-border-color)]",
          "bg-[var(--kbd-background-color)]",
          "text-[length:var(--text-xs)] font-medium",
          "text-[var(--kbd-text-color)]",
          "shadow-[var(--kbd-shadow)]",
          "fp-tabular-nums"
        ].join(" ")
      end

      def validate_keys!
        return if @keys.any?

        raise ArgumentError, "keys is required"
      end
    end
  end
end
