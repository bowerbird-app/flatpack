# frozen_string_literal: true

module FlatPack
  module EmptyState
    class Component < FlatPack::BaseComponent
      renders_one :actions
      renders_one :graphic

      alias_method :actions_slot, :actions
      alias_method :graphic_slot, :graphic

      undef_method :with_actions, :with_actions_content,
        :with_graphic, :with_graphic_content

      # Density for padding, title, and description. md matches the previous hard-coded look.
      # "py-8" "py-12" "py-16" "px-3" "px-4" "px-6" "text-base" "text-lg" "text-xl" "text-xs" "text-sm" "mb-1" "mb-2" "mb-3" "mb-4" "mb-6" "mb-8"
      SIZES = {
        sm: {
          container: "py-8 px-3",
          graphic_margin: "mb-2",
          title: "text-base font-semibold text-[var(--surface-content-color)] mb-1 fp-text-balance",
          description: "text-xs text-[var(--surface-muted-content-color)] max-w-md mb-4 fp-text-pretty",
          icon: :md,
          action_gap: "gap-2"
        },
        md: {
          container: "py-12 px-4",
          graphic_margin: "mb-3",
          title: "text-lg font-semibold text-[var(--surface-content-color)] mb-2 fp-text-balance",
          description: "text-sm text-[var(--surface-muted-content-color)] max-w-md mb-6 fp-text-pretty",
          icon: :lg,
          action_gap: "gap-3"
        },
        lg: {
          container: "py-16 px-6",
          graphic_margin: "mb-4",
          title: "text-xl font-semibold text-[var(--surface-content-color)] mb-3 fp-text-balance",
          description: "text-base text-[var(--surface-muted-content-color)] max-w-md mb-8 fp-text-pretty",
          icon: :xl,
          action_gap: "gap-4"
        }
      }.freeze

      def initialize(
        title:,
        description: nil,
        icon: nil,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @icon = normalize_icon(icon)
        @size = size.to_sym

        validate_title!
        validate_icon!
        validate_size!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_graphic,
            render_title,
            render_description,
            render_actions
          ].compact)
        end
      end

      def slot(*args, **kwargs, &block)
        return actions_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:actions, nil, *args, **kwargs, &block)
      end

      def slot?
        actions?
      end

      def actions(*args, **kwargs, &block)
        warn_deprecated_api(:actions, :slot)
        slot(*args, **kwargs, &block)
      end

      def graphic(*args, **kwargs, &block)
        return graphic_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:graphic, nil, *args, **kwargs, &block)
      end

      private

      def size_config
        SIZES.fetch(@size)
      end

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes(
          "fp-empty-state",
          "flex",
          "flex-col",
          "items-center",
          "justify-center",
          "text-center",
          size_config.fetch(:container)
        )
      end

      def render_graphic
        return content_tag(:div, graphic, class: size_config.fetch(:graphic_margin)) if graphic?
        return nil if @icon.nil?

        content_tag(:div, graphic_content, class: size_config.fetch(:graphic_margin))
      end

      def graphic_content
        render FlatPack::Shared::IconComponent.new(
          name: @icon,
          size: size_config.fetch(:icon),
          class: "text-[var(--surface-muted-content-color)]"
        )
      end

      def render_title
        content_tag(:h3, @title, class: size_config.fetch(:title))
      end

      def render_description
        return nil unless @description

        content_tag(:p, @description, class: size_config.fetch(:description))
      end

      def render_actions
        return nil unless slot?

        content_tag(:div, slot, class: action_classes)
      end

      def action_classes
        [
          "flex flex-wrap justify-center",
          size_config.fetch(:action_gap),
          ("mt-4" unless @description)
        ].compact.join(" ")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_icon!
        return if @icon.nil?
        return if @icon.is_a?(Symbol)
        raise ArgumentError, "Invalid icon: #{@icon.inspect}. Must be a symbol or string."
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def normalize_icon(icon)
        return nil if icon == false
        return icon.to_sym if icon.respond_to?(:to_sym)

        icon
      end
    end
  end
end
