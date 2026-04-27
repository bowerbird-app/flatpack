# frozen_string_literal: true

module FlatPack
  module Comments
    module InlineInput
      class Component < FlatPack::BaseComponent
        def initialize(
          placeholder: "Write a comment...",
          submit_label: "Comment",
          disabled: false,
          form: nil,
          name: "comment",
          value: nil,
          rows: 1,
          **system_arguments
        )
          super(**system_arguments)
          @placeholder = placeholder
          @submit_label = submit_label
          @disabled = disabled
          @form = form
          @name = name
          @value = value
          @rows = rows
        end

        def call
          content_tag(:div, **container_attributes) do
            safe_join([
              render_textarea,
              render_submit_button
            ])
          end
        end

        private

        def container_attributes
          merge_attributes(
            class: container_classes
          )
        end

        def container_classes
          classes(
            "flex items-center gap-2 rounded-[var(--comments-inline-input-radius)] border border-[var(--comments-composer-border-color)] bg-[var(--comments-composer-background-color)] px-3 py-1.5",
            "focus-within:ring-2 focus-within:ring-[var(--comments-composer-focus-ring-color)] focus-within:border-[var(--comments-composer-focus-border-color)]",
            "transition-colors duration-base",
            @disabled ? "opacity-60 pointer-events-none" : nil
          )
        end

        def render_textarea
          content_tag(:div, class: "min-w-0 flex-1") do
            render FlatPack::TextArea::Component.new(**textarea_component_arguments)
          end
        end

        def render_submit_button
          render FlatPack::Button::Component.new(**submit_button_arguments)
        end

        def textarea_component_arguments
          args = {
            name: @name,
            value: @value,
            rows: @rows,
            placeholder: @placeholder,
            disabled: @disabled,
            class: "min-w-0 w-full resize-none overflow-hidden border-0 bg-transparent px-0 py-1 text-sm text-[var(--comments-composer-text-color)] placeholder:text-[var(--comments-composer-placeholder-color)] focus:ring-0 focus:border-transparent"
          }
          args[:form] = @form if @form
          args
        end

        def submit_button_arguments
          args = {
            text: @submit_label,
            type: "submit",
            style: :primary,
            size: :sm,
            disabled: @disabled,
            class: "shrink-0 rounded-full"
          }
          args[:form] = @form if @form
          args
        end
      end
    end
  end
end
