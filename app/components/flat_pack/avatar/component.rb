# frozen_string_literal: true

module FlatPack
  module Avatar
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-6" "w-6" "text-[10px]" "h-8" "w-8" "text-xs" "h-10" "w-10" "text-sm" "h-12" "w-12" "text-base" "h-16" "w-16" "text-lg"
      SIZES = {
        xs: "h-6 w-6 text-[10px]",
        sm: "h-8 w-8 text-xs",
        md: "h-10 w-10 text-sm",
        lg: "h-12 w-12 text-base",
        xl: "h-16 w-16 text-lg"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "rounded-full" "rounded-xl" "rounded-md"
      SHAPES = {
        circle: "rounded-full",
        rounded: "rounded-xl",
        square: "rounded-md"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-emerald-500" "bg-zinc-400" "dark:bg-zinc-600" "bg-rose-500" "bg-amber-500"
      STATUS_COLORS = {
        online: "bg-emerald-500",
        offline: "bg-zinc-400 dark:bg-zinc-600",
        busy: "bg-rose-500",
        away: "bg-amber-500"
      }.freeze

      def initialize(
        src: nil,
        alt: nil,
        name: nil,
        initials: nil,
        size: :md,
        shape: :circle,
        status: nil,
        href: nil,
        **system_arguments
      )
        super(**system_arguments)
        @src = src
        @alt = alt || name || "Avatar"
        @name = name
        @initials = initials
        @size = size.to_sym
        @shape = shape.to_sym
        @status = status&.to_sym
        @href = href

        validate_size!
        validate_shape!
        validate_status! if @status
      end

      def call
        wrapper_tag do
          safe_join([
            render_image_or_fallback,
            render_status_indicator
          ])
        end
      end

      private

      def wrapper_tag(&block)
        if @href
          content_tag(:a, href: @href, **wrapper_attributes, &block)
        else
          content_tag(:span, **wrapper_attributes, &block)
        end
      end

      def wrapper_attributes
        merge_attributes(
          class: wrapper_classes
        )
      end

      def wrapper_classes
        classes(
          "relative inline-flex items-center justify-center shrink-0",
          "bg-[var(--color-muted)] text-[var(--color-foreground)]",
          "font-medium select-none overflow-hidden",
          SIZES.fetch(@size),
          SHAPES.fetch(@shape),
          @href ? "hover:opacity-80 transition-opacity duration-[var(--transition-base)]" : nil
        )
      end

      def render_image_or_fallback
        if @src.present?
          render_image
        elsif computed_initials.present?
          render_initials
        else
          render_generic_icon
        end
      end

      def render_image
        content_tag(:img,
          nil,
          src: @src,
          alt: @alt,
          loading: "lazy",
          decoding: "async",
          class: "h-full w-full object-cover"
        )
      end

      def render_initials
        content_tag(:span, computed_initials, class: "uppercase font-semibold")
      end

      def render_generic_icon
        # Generic user icon SVG
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 24 24",
          fill: "currentColor",
          class: "h-3/5 w-3/5 opacity-50") do
          safe_join([
            content_tag(:path, nil, d: "M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 3c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3zm0 14.2c-2.5 0-4.71-1.28-6-3.22.03-1.99 4-3.08 6-3.08 1.99 0 5.97 1.09 6 3.08-1.29 1.94-3.5 3.22-6 3.22z")
          ])
        end
      end

      def render_status_indicator
        return unless @status

        content_tag(:span,
          nil,
          class: status_indicator_classes,
          "aria-hidden": "true"
        )
      end

      def status_indicator_classes
        size_class = case @size
        when :xs then "h-1.5 w-1.5"
        when :sm then "h-2 w-2"
        when :md then "h-2.5 w-2.5"
        when :lg then "h-3 w-3"
        when :xl then "h-4 w-4"
        end

        classes(
          "absolute bottom-0 right-0 block rounded-full",
          "ring-2 ring-white dark:ring-zinc-900",
          size_class,
          STATUS_COLORS.fetch(@status)
        )
      end

      def computed_initials
        return @initials if @initials.present?
        return nil unless @name.present?

        # Extract initials from name (first letter of first two words)
        parts = @name.strip.split(/\s+/)
        if parts.length >= 2
          "#{parts[0][0]}#{parts[1][0]}"
        elsif parts.length == 1 && parts[0].length >= 2
          parts[0][0..1]
        elsif parts.length == 1
          parts[0][0]
        else
          nil
        end
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_shape!
        return if SHAPES.key?(@shape)
        raise ArgumentError, "Invalid shape: #{@shape}. Must be one of: #{SHAPES.keys.join(", ")}"
      end

      def validate_status!
        return if STATUS_COLORS.key?(@status)
        raise ArgumentError, "Invalid status: #{@status}. Must be one of: #{STATUS_COLORS.keys.join(", ")}"
      end
    end
  end
end
