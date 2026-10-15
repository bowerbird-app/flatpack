# frozen_string_literal: true

module FlatPack
  module EmptyState
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # "py-[var(--empty-state-padding-y-sm)]" "px-[var(--empty-state-padding-x-sm)]"
      # "py-[var(--empty-state-padding-y-md)]" "px-[var(--empty-state-padding-x-md)]"
      # "py-[var(--empty-state-padding-y-lg)]" "px-[var(--empty-state-padding-x-lg)]"
      # "mb-[var(--empty-state-gap-sm)]" "mb-[var(--empty-state-gap-md)]" "mb-[var(--empty-state-gap-lg)]"
      # "mb-[var(--empty-state-title-gap-sm)]" "mb-[var(--empty-state-title-gap-md)]" "mb-[var(--empty-state-title-gap-lg)]"
      # "mb-[var(--empty-state-block-gap-sm)]" "mb-[var(--empty-state-block-gap-md)]" "mb-[var(--empty-state-block-gap-lg)]"
      # "max-w-[var(--empty-state-measure-sm)]" "max-w-[var(--empty-state-measure-md)]"
      # "max-w-[var(--empty-state-measure-lg)]" "max-w-[var(--empty-state-measure-full)]"
      # "text-[length:var(--text-xs)]" "text-[length:var(--text-sm)]" "text-[length:var(--text-base)]"
      # "text-[length:var(--text-lg)]" "text-[length:var(--text-xl)]" "text-[length:var(--text-2xl)]"
      # "fp-display" "fp-text-balance" "fp-text-pretty" "font-semibold"
      # "w-full" "min-w-0" "flex" "flex-col" "items-center" "justify-center" "text-center"
      SIZES = {
        sm: {
          padding: "py-[var(--empty-state-padding-y-sm)] px-[var(--empty-state-padding-x-sm)]",
          visual_margin: "mb-[var(--empty-state-gap-sm)]",
          title_gap: "mb-[var(--empty-state-title-gap-sm)]",
          block_gap: "mb-[var(--empty-state-block-gap-sm)]",
          description: "text-[length:var(--text-xs)]",
          icon: :md,
          collection_gap: :sm,
          action_gap: "gap: var(--empty-state-gap-sm)"
        },
        md: {
          padding: "py-[var(--empty-state-padding-y-md)] px-[var(--empty-state-padding-x-md)]",
          visual_margin: "mb-[var(--empty-state-gap-md)]",
          title_gap: "mb-[var(--empty-state-title-gap-md)]",
          block_gap: "mb-[var(--empty-state-block-gap-md)]",
          description: "text-[length:var(--text-sm)]",
          icon: :lg,
          collection_gap: :md,
          action_gap: "gap: var(--empty-state-gap-md)"
        },
        lg: {
          padding: "py-[var(--empty-state-padding-y-lg)] px-[var(--empty-state-padding-x-lg)]",
          visual_margin: "mb-[var(--empty-state-gap-lg)]",
          title_gap: "mb-[var(--empty-state-title-gap-lg)]",
          block_gap: "mb-[var(--empty-state-block-gap-lg)]",
          description: "text-[length:var(--text-base)]",
          icon: :xl,
          collection_gap: :lg,
          action_gap: "gap: var(--empty-state-gap-lg)"
        }
      }.freeze

      # Text scale for the heading. :display opts into cover type. Omit to follow size.
      TITLE_SIZES = {
        xs: "text-[length:var(--text-xs)]",
        sm: "text-[length:var(--text-sm)]",
        base: "text-[length:var(--text-base)]",
        lg: "text-[length:var(--text-lg)]",
        xl: "text-[length:var(--text-xl)]",
        xxl: "text-[length:var(--text-2xl)]",
        display: "fp-display"
      }.freeze

      DEFAULT_TITLE_SIZE = {sm: :base, md: :lg, lg: :xl}.freeze

      # Content measure. The root still fills its container. full is max-width: none.
      WIDTHS = {
        sm: "max-w-[var(--empty-state-measure-sm)]",
        md: "max-w-[var(--empty-state-measure-md)]",
        lg: "max-w-[var(--empty-state-measure-lg)]",
        full: "max-w-[var(--empty-state-measure-full)]"
      }.freeze

      LAYOUTS = %i[wrap stack].freeze
      ICON_VARIANTS = FlatPack::Shared::IconComponent::VIEWBOXES.keys.freeze

      renders_one :graphic
      renders_one :media, FlatPack::Media::Component
      renders_many :items

      alias_method :graphic_slot, :graphic
      alias_method :media_slot, :media

      undef_method :with_graphic, :with_graphic_content,
        :with_media, :with_media_content,
        :with_item, :with_item_content

      def initialize(
        title:,
        description: nil,
        icon: nil,
        icon_variant: nil,
        size: :md,
        title_size: nil,
        width: :md,
        layout: :wrap,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @icon = normalize_icon(icon)
        @icon_variant = icon_variant&.to_sym
        @size = size.to_sym
        @title_size = title_size&.to_sym
        @width = width.to_sym
        @layout = layout.to_sym

        validate_title!
        validate_icon!
        validate_icon_variant!
        validate_size!
        validate_title_size!
        validate_width!
        validate_layout!
      end

      def before_render
        return unless graphic? && media?

        raise ArgumentError, "Pass graphic or media, not both."
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([render_visual, render_copy].compact)
        end
      end

      def graphic(*args, **kwargs, &block)
        return graphic_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:graphic, nil, *args, **kwargs, &block)
      end

      def media(**kwargs, &block)
        return media_slot if kwargs.empty? && !block_given?

        set_slot(:media, nil, **kwargs, &block)
      end

      def item(**kwargs, &block)
        set_slot(:items, nil, **kwargs, &block)
      end

      private

      def size_config
        SIZES.fetch(@size)
      end

      def container_attributes
        merge_attributes(class: container_classes)
      end

      # Block-level flex column with no width and no max-width, so in normal
      # flow the root fills its container. width: caps the text, not this box.
      def container_classes
        classes(
          "fp-empty-state",
          "flex",
          "flex-col",
          "items-center",
          "justify-center",
          "text-center",
          size_config.fetch(:padding)
        )
      end

      def render_visual
        return nil unless visual?

        content_tag(:div, visual_body, class: visual_classes)
      end

      def visual?
        graphic? || media? || @icon
      end

      def visual_classes
        ["flex", "w-full", "justify-center", size_config.fetch(:visual_margin)].join(" ")
      end

      def visual_body
        if graphic?
          content_tag(:div, graphic, class: "w-full")
        elsif media?
          content_tag(:div, media, class: media_classes)
        else
          icon_tag
        end
      end

      def media_classes
        ["w-full", WIDTHS.fetch(@width)].join(" ")
      end

      def icon_tag
        arguments = {
          name: @icon,
          size: size_config.fetch(:icon),
          class: "text-[var(--surface-muted-content-color)]"
        }
        arguments[:variant] = @icon_variant if @icon_variant

        render FlatPack::Shared::IconComponent.new(**arguments)
      end

      def render_copy
        content_tag(:div, class: copy_classes) do
          safe_join([render_title, render_description, render_actions].compact)
        end
      end

      def copy_classes
        ["flex", "w-full", "min-w-0", "flex-col", "items-center", WIDTHS.fetch(@width)].join(" ")
      end

      def render_title
        content_tag(:h3, @title, class: title_classes)
      end

      def title_classes
        [
          "w-full",
          title_size_class,
          ("font-semibold" unless display_title?),
          "text-[var(--surface-content-color)]",
          "fp-text-balance",
          title_margin_class
        ].compact.join(" ")
      end

      def title_size_class
        TITLE_SIZES.fetch(resolved_title_size)
      end

      def resolved_title_size
        @title_size || DEFAULT_TITLE_SIZE.fetch(@size)
      end

      def display_title?
        resolved_title_size == :display
      end

      def title_margin_class
        if @description
          size_config.fetch(:title_gap)
        elsif items?
          size_config.fetch(:block_gap)
        end
      end

      def render_description
        return nil unless @description

        content_tag(:p, @description, class: description_classes)
      end

      def description_classes
        [
          "w-full",
          size_config.fetch(:description),
          "text-[var(--surface-muted-content-color)]",
          "fp-text-pretty",
          (size_config.fetch(:block_gap) if items?)
        ].compact.join(" ")
      end

      def render_actions
        return nil unless items?

        render(FlatPack::Collection::Component.new(**action_arguments)) do |collection|
          items.each do |action|
            collection.with_item { action.to_s }
          end
        end
      end

      def action_arguments
        {
          layout: @layout,
          gap: size_config.fetch(:collection_gap),
          class: "w-full items-center justify-center",
          style: size_config.fetch(:action_gap)
        }
      end

      def validate_title!
        return if @title.present?

        raise ArgumentError, "title is required"
      end

      def validate_icon!
        return if @icon.nil?
        return if @icon.is_a?(Symbol) && @icon.to_s.present?

        raise ArgumentError, "Invalid icon: #{@icon.inspect}. Must be a symbol or string."
      end

      def validate_icon_variant!
        if @icon_variant && @icon.nil?
          raise ArgumentError, "icon_variant requires icon."
        end
        return if @icon_variant.nil?
        return if ICON_VARIANTS.include?(@icon_variant)

        raise ArgumentError, "Invalid icon_variant: #{@icon_variant.inspect}. Must be one of: #{ICON_VARIANTS.join(", ")}."
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_title_size!
        return if @title_size.nil? || TITLE_SIZES.key?(@title_size)

        raise ArgumentError, "Invalid title_size: #{@title_size.inspect}. Must be one of: #{TITLE_SIZES.keys.join(", ")}."
      end

      def validate_width!
        return if WIDTHS.key?(@width)

        raise ArgumentError, "Invalid width: #{@width.inspect}. Must be one of: #{WIDTHS.keys.join(", ")}."
      end

      def validate_layout!
        return if LAYOUTS.include?(@layout)

        raise ArgumentError, "Invalid layout: #{@layout.inspect}. Must be one of: #{LAYOUTS.join(", ")}."
      end

      def normalize_icon(icon)
        return nil if icon == false || icon.nil?
        return icon.to_sym if icon.is_a?(Symbol) || icon.is_a?(String)

        icon
      end
    end
  end
end
