# frozen_string_literal: true

module FlatPack
  module Skeleton
    class Component < FlatPack::BaseComponent
      # Base shape per variant. Height (and avatar/button width) come from SIZES.
      VARIANTS = {
        text: "w-full rounded",
        title: "w-3/4 rounded",
        avatar: "rounded-full",
        button: "rounded-[var(--radius-md)]",
        rectangle: "w-full rounded-[var(--radius-lg)]"
      }.freeze

      # Density on top of variant. md matches the previous hard-coded heights.
      # "h-3" "h-4" "h-5" "h-6" "h-8" "h-10" "h-12" "h-14" "h-24" "h-32" "h-40"
      # "w-10" "w-12" "w-14" "w-20" "w-24" "w-28"
      SIZES = {
        sm: {
          text: "h-3",
          title: "h-6",
          avatar: "h-10 w-10",
          button: "h-8 w-20",
          rectangle: "h-24"
        },
        md: {
          text: "h-4",
          title: "h-8",
          avatar: "h-12 w-12",
          button: "h-10 w-24",
          rectangle: "h-32"
        },
        lg: {
          text: "h-5",
          title: "h-10",
          avatar: "h-14 w-14",
          button: "h-12 w-28",
          rectangle: "h-40"
        }
      }.freeze

      def initialize(
        variant: :text,
        width: nil,
        height: nil,
        shimmer: true,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @variant = variant.to_sym
        @width = width
        @height = height
        @shimmer = shimmer
        @size = size.to_sym

        validate_variant!
        validate_size!
      end

      def call
        content_tag(:div, nil, **skeleton_attributes)
      end

      private

      def skeleton_attributes
        attrs = {
          class: skeleton_classes,
          aria: {busy: true, label: "Loading…"},
          role: "status"
        }

        style = custom_size_style
        attrs[:style] = style if style

        merge_attributes(**attrs)
      end

      def skeleton_classes
        base = "bg-[var(--skeleton-background-color)]"
        variant_classes = VARIANTS.fetch(@variant)
        size_classes = SIZES.fetch(@size).fetch(@variant)

        classes(base, shimmer_classes, size_classes, variant_classes)
      end

      def shimmer_classes
        return unless @shimmer

        "relative overflow-hidden before:pointer-events-none before:absolute before:inset-0 before:content-[''] before:bg-[linear-gradient(110deg,transparent_20%,var(--skeleton-shimmer-highlight-color)_45%,transparent_70%)] before:translate-x-[-100%] before:animate-[fp-skeleton-shimmer_var(--skeleton-shimmer-duration)_linear_infinite] motion-reduce:before:animate-none"
      end

      def custom_size_style
        custom_styles = []
        custom_styles << "width: #{@width}" if @width.present?
        custom_styles << "height: #{@height}" if @height.present?
        return if custom_styles.empty?

        existing_style = @system_arguments[:style] || @system_arguments["style"]
        return custom_styles.join("; ") unless existing_style.present?

        "#{existing_style.to_s.rstrip.sub(/;+\z/, "")}; #{custom_styles.join("; ")}"
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)
        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
