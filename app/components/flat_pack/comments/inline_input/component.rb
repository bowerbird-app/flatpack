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
            class: container_classes,
            data: {
              controller: "flat-pack--text-area"
            }
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
          attrs = {
            name: @name,
            rows: @rows,
            placeholder: @placeholder,
            disabled: @disabled,
            class: "min-w-0 flex-1 resize-none overflow-hidden border-0 bg-transparent px-0 py-1 text-sm text-[var(--comments-composer-text-color)] placeholder:text-[var(--comments-composer-placeholder-color)] focus:outline-none focus:ring-0",
            data: {
              flat_pack__text_area_target: "textarea",
              action: "input->flat-pack--text-area#autoExpand"
            }
          }

          attrs[:form] = @form if @form
          content_tag(:textarea, @value, **attrs)
        end

        def render_submit_button
          button_attrs = {
            type: "submit",
            disabled: @disabled,
            class: "shrink-0 rounded-full px-3 py-1 text-sm font-medium text-[var(--comments-composer-submit-text-color)] bg-[var(--comments-composer-submit-background-color)] hover:bg-[var(--comments-composer-submit-hover-background-color)] transition-colors duration-base disabled:opacity-50"
          }

          button_attrs[:form] = @form if @form

          content_tag(:button, @submit_label, **button_attrs)
        end
      end
    end
  end
end
