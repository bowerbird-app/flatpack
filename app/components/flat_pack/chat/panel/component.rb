# frozen_string_literal: true

module FlatPack
  module Chat
    module Panel
      class Component < FlatPack::BaseComponent
        renders_one :header
        renders_one :right_header
        renders_one :messages
        renders_one :composer

        undef_method :with_header, :with_header_content
        undef_method :with_right_header, :with_right_header_content
        undef_method :with_messages, :with_messages_content
        undef_method :with_composer, :with_composer_content

        def initialize(**system_arguments)
          super
        end

        def header(*args, **kwargs, &block)
          return get_slot(:header) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:header, nil, *args, **kwargs, &block)
        end

        def right_header(*args, **kwargs, &block)
          return get_slot(:right_header) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:right_header, nil, *args, **kwargs, &block)
        end

        def messages(*args, **kwargs, &block)
          return get_slot(:messages) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:messages, nil, *args, **kwargs, &block)
        end

        def composer(*args, **kwargs, &block)
          return get_slot(:composer) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:composer, nil, *args, **kwargs, &block)
        end

        def call
          content_tag(:div, **panel_attributes) do
            safe_join([
              (render_header_section if header? || right_header?),
              (render_messages_section if messages?),
              (render_composer_section if composer?)
            ].compact)
          end
        end

        private

        def render_header_section
          return render_split_header_section if right_header?

          content_tag(:div, class: header_classes) do
            header.to_s
          end
        end

        def render_split_header_section
          content_tag(:div, class: split_header_classes) do
            safe_join([
              (render_header_part if header?),
              render_right_header_part
            ].compact)
          end
        end

        def render_header_part
          content_tag(
            :div,
            class: "min-w-0 flex-1",
            data: {flat_pack_chat_panel_part: "header"}
          ) do
            header.to_s
          end
        end

        def render_right_header_part
          content_tag(
            :div,
            class: right_header_part_classes,
            data: {flat_pack_chat_panel_part: "right-header"}
          ) do
            right_header.to_s
          end
        end

        # w-min does not grow, so a lone right part needs ml-auto to sit on the right.
        # "ml-auto flex shrink-0 w-min items-center justify-end"
        # "flex shrink-0 w-min items-center justify-end"
        def right_header_part_classes
          return "ml-auto flex shrink-0 w-min items-center justify-end" unless header?

          "flex shrink-0 w-min items-center justify-end"
        end

        def render_messages_section
          messages.to_s
        end

        def render_composer_section
          composer.to_s
        end

        def panel_attributes
          merge_attributes(
            class: panel_classes
          )
        end

        def panel_classes
          classes(
            "flex flex-col",
            "h-full min-h-0",
            "overflow-hidden"
          )
        end

        def header_classes
          classes(*header_chrome_classes)
        end

        def split_header_classes
          classes("flex", *header_chrome_classes)
        end

        def header_chrome_classes
          [
            "flex-shrink-0",
            "border-b border-[var(--chat-header-border-color)]",
            "bg-[var(--chat-header-background-color)]"
          ]
        end
      end
    end
  end
end
