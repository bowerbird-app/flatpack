# frozen_string_literal: true

module FlatPack
  module Skeleton
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-4" "h-6" "h-8" "h-10" "h-12" "w-full" "w-3/4" "w-1/2" "w-1/4" "rounded" "rounded-md" "rounded-lg" "rounded-full"
      VARIANTS = {
        text: "h-4 w-full rounded",
        title: "h-8 w-3/4 rounded",
        avatar: "h-12 w-12 rounded-full",
        button: "h-10 w-24 rounded-md",
        rectangle: "h-32 w-full rounded-lg"
      }.freeze

      def initialize(
        variant: :text,
        width: nil,
        height: nil,
        shimmer: true,
        **system_arguments
      )
        super(**system_arguments)
        @variant = variant.to_sym
        @width = width
        @height = height
        @shimmer = shimmer

        validate_variant!
      end

      def call
        content_tag(:div, nil, **skeleton_attributes)
      end

      private

      def skeleton_attributes
        merge_attributes(
          class: skeleton_classes,
          aria: {busy: true, label: "Loading..."},
          role: "status"
        )
      end

      def skeleton_classes
        base = "bg-[var(--surface-muted-background-color)]"
        variant_classes = VARIANTS.fetch(@variant)

        classes(base, shimmer_classes, variant_classes, custom_size_classes)
      end

      def shimmer_classes
        return unless @shimmer

        "relative overflow-hidden before:pointer-events-none before:absolute before:inset-0 before:content-[''] before:bg-[linear-gradient(110deg,transparent_20%,rgb(255_255_255_/_0.45)_45%,transparent_70%)] before:translate-x-[-100%] before:animate-[fp-skeleton-shimmer_1.35s_linear_infinite] motion-reduce:before:animate-none"
      end

      def custom_size_classes
        custom = []
        custom << "w-[#{@width}]" if @width
        custom << "h-[#{@height}]" if @height
        custom.join(" ")
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)
        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end
    end
  end
end
