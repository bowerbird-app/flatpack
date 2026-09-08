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

      def initialize(
        title:,
        description: nil,
        icon: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @description = description
        @icon = normalize_icon(icon)

        validate_title!
        validate_icon!
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
          "py-12",
          "px-4"
        )
      end

      def render_graphic
        return content_tag(:div, graphic, class: "mb-3") if graphic?
        return nil if @icon.nil?

        content_tag(:div, graphic_content, class: "mb-3")
      end

      def graphic_content
        render FlatPack::Shared::IconComponent.new(
          name: @icon,
          size: :lg,
          class: "text-[var(--surface-muted-content-color)]"
        )
      end

      def render_title
        content_tag(:h3, @title, class: "text-lg font-semibold text-[var(--surface-content-color)] mb-2 fp-text-balance")
      end

      def render_description
        return nil unless @description

        content_tag(:p, @description, class: "text-sm text-[var(--surface-muted-content-color)] max-w-md mb-6 fp-text-pretty")
      end

      def render_actions
        return nil unless slot?

        content_tag(:div, slot, class: action_classes)
      end

      def action_classes
        ["flex gap-3 flex-wrap justify-center", ("mt-4" unless @description)].compact.join(" ")
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

      def normalize_icon(icon)
        return nil if icon == false
        return icon.to_sym if icon.respond_to?(:to_sym)

        icon
      end
    end
  end
end
