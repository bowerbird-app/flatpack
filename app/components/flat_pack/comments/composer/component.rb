# frozen_string_literal: true

module FlatPack
  module Comments
    module Composer
      class Component < FlatPack::BaseComponent
        renders_one :toolbar
        renders_one :attachments
        renders_one :actions

        def initialize(
          placeholder: "Write a comment...",
          submit_label: "Comment",
          cancel_label: "Cancel",
          show_cancel: false,
          disabled: false,
          compact: false,
          form: nil,
          name: "comment",
          value: nil,
          rows: 3,
          **system_arguments
        )
          super(**system_arguments)
          @placeholder = placeholder
          @submit_label = submit_label
          @cancel_label = cancel_label
          @show_cancel = show_cancel
          @disabled = disabled
          @compact = compact
          @form = form
          @name = name
          @value = value
          @rows = rows
        end

        def call
          content_tag(:div, **composer_attributes) do
            safe_join([
              render_textarea_section,
              render_toolbar_section,
              render_attachments_section,
              render_actions_section
            ].compact)
          end
        end

        private

        def composer_attributes
          merge_attributes(
            class: composer_classes
          )
        end

        def composer_classes
          classes(
            "rounded-lg border border-[var(--color-border)] bg-[var(--color-background)]",
            "focus-within:ring-2 focus-within:ring-[var(--color-ring)] focus-within:border-[var(--color-ring)]",
            "transition-all duration-[var(--transition-base)]",
            @disabled ? "opacity-60 pointer-events-none" : nil
          )
        end

        def render_textarea_section
          content_tag(:div, class: @compact ? "p-2" : "p-3") do
            textarea_attrs = {
              name: @name,
              rows: @rows,
              placeholder: @placeholder,
              disabled: @disabled,
              class: "w-full resize-none bg-transparent text-sm text-[var(--color-foreground)] placeholder:text-[var(--color-muted-foreground)] focus:outline-none"
            }
            textarea_attrs[:form] = @form if @form

            content_tag(:textarea, @value, **textarea_attrs)
          end
        end

        def render_toolbar_section
          return unless toolbar?

          content_tag(:div, toolbar, class: "px-3 pb-2 border-t border-[var(--color-border)]")
        end

        def render_attachments_section
          return unless attachments?

          content_tag(:div, attachments, class: "px-3 pb-2")
        end

        def render_actions_section
          if actions?
            content_tag(:div, actions, class: action_section_classes)
          else
            render_default_actions
          end
        end

        def render_default_actions
          content_tag(:div, class: action_section_classes) do
            content_tag(:div, class: "flex items-center justify-end gap-2") do
              safe_join([
                @show_cancel ? render_cancel_button : nil,
                render_submit_button
              ].compact)
            end
          end
        end

        def action_section_classes
          classes(
            "border-t border-[var(--color-border)] bg-[var(--color-muted)]/30",
            @compact ? "px-2 py-1.5" : "px-3 py-2"
          )
        end

        def render_cancel_button
          content_tag(:button,
            type: "button",
            disabled: @disabled,
            class: "px-3 py-1.5 text-sm font-medium text-[var(--color-foreground)] hover:bg-[var(--color-muted)] rounded-md transition-colors duration-[var(--transition-base)]") do
            @cancel_label
          end
        end

        def render_submit_button
          content_tag(:button,
            type: "submit",
            disabled: @disabled,
            class: "px-3 py-1.5 text-sm font-medium text-white bg-[var(--color-primary)] hover:bg-[var(--color-primary)]/90 rounded-md transition-colors duration-[var(--transition-base)] disabled:opacity-50") do
            @submit_label
          end
        end
      end
    end
  end
end
