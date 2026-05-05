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
          rich_text: false,
          rich_text_options: {},
          avatar: nil,
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
          @rich_text = rich_text
          @rich_text_options = rich_text_options
          @avatar = avatar.is_a?(Hash) ? avatar.symbolize_keys : avatar
        end

        def call
          content_tag(:div, **composer_attributes) do
            safe_join([
              render_avatar,
              render_content_column
            ].compact)
          end
        end

        def toolbar(*args, **kwargs, &block)
          return get_slot(:toolbar) if args.empty? && kwargs.empty? && !block

          set_slot(:toolbar, nil, *args, **kwargs, &block)
        end

        def attachments(*args, **kwargs, &block)
          return get_slot(:attachments) if args.empty? && kwargs.empty? && !block

          set_slot(:attachments, nil, *args, **kwargs, &block)
        end

        def actions(*args, **kwargs, &block)
          return get_slot(:actions) if args.empty? && kwargs.empty? && !block

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
            "flex items-start gap-4",
            @disabled ? "opacity-60 pointer-events-none" : nil
          )
        end

        def render_avatar
          return if @compact

          avatar_options = {
            name: @avatar.is_a?(Hash) ? (@avatar[:name] || "You") : "You",
            alt: @avatar.is_a?(Hash) ? @avatar[:alt] : nil,
            src: @avatar.is_a?(Hash) ? @avatar[:src] : nil,
            initials: @avatar.is_a?(Hash) ? @avatar[:initials] : nil,
            size: :md,
            shape: :circle
          }.compact

          content_tag(:div, class: "shrink-0") do
            FlatPack::Avatar::Component.new(**avatar_options).render_in(view_context)
          end
        end

        def render_content_column
          content_tag(:div, class: "flex-1") do
            safe_join([
              render_textarea_section,
              render_toolbar_section,
              render_attachments_section,
              render_actions_section
            ].compact)
          end
        end

        def render_textarea_section
          content_tag(:div, class: textarea_shell_classes) do
            safe_join([
              render(FlatPack::TextArea::Component.new(**textarea_component_arguments)),
              render_floating_submit_button
            ].compact)
          end
        end

        def render_toolbar_section
          return unless toolbar?

          content_tag(:div, toolbar, class: "px-4 pt-3")
        end

        def render_attachments_section
          return unless attachments?

          content_tag(:div, attachments, class: "px-4 pt-3")
        end

        def render_actions_section
          return content_tag(:div, actions, class: action_section_classes) if actions?
          return render_default_actions if @show_cancel

          nil
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
            @compact ? "px-2 pt-3" : "px-4 pt-4"
          )
        end

        def textarea_shell_classes
          classes(
            "relative overflow-hidden rounded-xl border border-[var(--comments-composer-border-color)] bg-[var(--comments-composer-background-color)] shadow-sm transition-all duration-base",
            "focus-within:border-[var(--comments-composer-focus-border-color)] focus-within:ring-2 focus-within:ring-[var(--comments-composer-focus-ring-color)]",
            @compact ? "min-h-[5.5rem] px-3 py-3 pr-14" : "min-h-24 px-4 py-4 pr-16"
          )
        end

        def render_floating_submit_button
          return if actions? || @show_cancel

          content_tag(:button,
            type: "submit",
            class: "absolute bottom-4 right-4 inline-flex h-10 w-10 items-center justify-center rounded-xl bg-[var(--comments-composer-submit-background-color)] text-[var(--comments-composer-submit-text-color)] shadow-lg transition-colors duration-base hover:bg-[var(--comments-composer-submit-hover-background-color)]",
            disabled: @disabled,
            form: @form,
            "aria-label": @submit_label) do
            safe_join([
              content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor",
                class: "h-5 w-5 rotate-90") do
                content_tag(:path, nil,
                  "stroke-linecap": "round",
                  "stroke-linejoin": "round",
                  "stroke-width": "2",
                  d: "M12 19l9 2-9-18-9 18 9-2zm0 0v-8")
              end,
              content_tag(:span, @submit_label, class: "sr-only")
            ])
          end
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
            rich_text: @rich_text,
            rich_text_options: @rich_text_options,
            class: classes(
              "w-full resize-none border-0 bg-transparent px-0 py-0 text-sm text-[var(--comments-composer-text-color)] placeholder:text-[var(--comments-composer-placeholder-color)] focus:ring-0 focus:border-transparent",
              @compact ? "min-h-[4rem]" : "min-h-16"
            )
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
