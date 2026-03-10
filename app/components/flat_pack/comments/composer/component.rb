# frozen_string_literal: true

module FlatPack
  module Comments
    module Composer
      class Component < FlatPack::BaseComponent
        renders_one :toolbar
        renders_one :attachments
        renders_one :actions

        undef_method :with_toolbar, :with_toolbar_content,
          :with_attachments, :with_attachments_content,
          :with_actions, :with_actions_content

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

        def toolbar(*args, **kwargs, &block)
          return get_slot(:toolbar) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:toolbar, nil, *args, **kwargs, &block)
        end

        def attachments(*args, **kwargs, &block)
          return get_slot(:attachments) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:attachments, nil, *args, **kwargs, &block)
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

        private

        def composer_attributes
          merge_attributes(
            class: composer_classes
          )
        end

        def composer_classes
          classes(
            "rounded-lg border border-[var(--comments-composer-border-color)] bg-[var(--comments-composer-background-color)]",
            "focus-within:ring-2 focus-within:ring-[var(--comments-composer-focus-ring-color)] focus-within:border-[var(--comments-composer-focus-border-color)]",
            "transition-all duration-base",
            @disabled ? "opacity-60 pointer-events-none" : nil
          )
        end

        def render_textarea_section
          content_tag(:div, class: @compact ? "p-2" : "p-3") do
            render FlatPack::TextArea::Component.new(**textarea_component_arguments)
          end
        end

        def render_toolbar_section
          return unless toolbar?

          content_tag(:div, toolbar, class: "px-3 pb-2 border-t border-[var(--surface-border-color)]")
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
            "border-t border-[var(--comments-composer-border-color)] bg-[var(--comments-composer-actions-background-color)]",
            @compact ? "px-2 py-1.5" : "px-3 py-2"
          )
        end

        def render_cancel_button
          render FlatPack::Button::Component.new(**cancel_button_arguments)
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
            class: "w-full resize-none border-0 bg-transparent px-0 py-0 text-sm text-[var(--comments-composer-text-color)] placeholder:text-[var(--comments-composer-placeholder-color)] focus:ring-0 focus:border-transparent"
          }
          args[:form] = @form if @form
          args
        end

        def cancel_button_arguments
          args = {
            text: @cancel_label,
            type: "button",
            style: :ghost,
            size: :sm,
            disabled: @disabled
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
            disabled: @disabled
          }
          args[:form] = @form if @form
          args
        end
      end
    end
  end
end
