# frozen_string_literal: true

module FlatPack
  module TopNav
    module Search
      class Component < FlatPack::BaseComponent
        def initialize(
          placeholder: "Search...",
          name: "q",
          value: nil,
          **system_arguments
        )
          super(**system_arguments)
          @placeholder = placeholder
          @name = name
          @value = value
        end

        def call
          content_tag(:div, **wrapper_attributes) do
            safe_join([
              render_icon,
              render_input
            ].compact)
          end
        end

        private

        def render_icon
          content_tag(:span, class: icon_wrapper_classes) do
            render FlatPack::Shared::IconComponent.new(
              name: :search,
              size: :sm
            )
          end
        end

        def render_input
          tag.input(**input_attributes)
        end

        def wrapper_attributes
          merge_attributes(
            class: wrapper_classes
          )
        end

        def wrapper_classes
          classes(
            "relative",
            "flex",
            "items-center",
            "w-full",
            "max-w-md"
          )
        end

        def icon_wrapper_classes
          classes(
            "absolute",
            "left-3",
            "pointer-events-none",
            "text-[var(--color-text-muted)]"
          )
        end

        def input_attributes
          {
            type: "text",
            name: @name,
            value: @value,
            placeholder: @placeholder,
            class: input_classes
          }.compact
        end

        def input_classes
          classes(
            "w-full",
            "pl-10",
            "pr-4",
            "py-2",
            "text-sm",
            "bg-[var(--color-muted)]",
            "border",
            "border-transparent",
            "rounded-lg",
            "focus:outline-none",
            "focus:ring-2",
            "focus:ring-[var(--color-primary)]",
            "focus:border-transparent",
            "placeholder:text-[var(--color-text-muted)]"
          )
        end
      end
    end
  end
end
