# frozen_string_literal: true

module FlatPack
  module Chat
    module Panel
      class Component < FlatPack::BaseComponent
        renders_one :header
        renders_one :right_header
        renders_one :right_header_mobile
        renders_one :messages
        renders_one :composer

        undef_method :with_header, :with_header_content
        undef_method :with_right_header, :with_right_header_content
        undef_method :with_right_header_mobile, :with_right_header_mobile_content
        undef_method :with_messages, :with_messages_content
        undef_method :with_composer, :with_composer_content

        # "shrink-0 w-min items-center justify-end"
        RIGHT_PART_BASE = "shrink-0 w-min items-center justify-end"

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

        def right_header_mobile(*args, **kwargs, &block)
          return get_slot(:right_header_mobile) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:right_header_mobile, nil, *args, **kwargs, &block)
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
              (render_header_section if header? || right_header? || right_header_mobile?),
              (render_messages_section if messages?),
              (render_composer_section if composer?)
            ].compact)
          end
        end

        private

        def render_header_section
          return render_split_header_section if right_header? || right_header_mobile?

          content_tag(:div, class: header_classes) do
            header.to_s
          end
        end

        def render_split_header_section
          content_tag(:div, class: split_header_classes) do
            safe_join([
              (render_header_part if header?),
              (render_right_header_part if right_header?),
              (render_right_header_mobile_part if right_header_mobile?)
            ].compact)
          end
        end

        def render_header_part
          content_tag(
            :div,
            class: "flex min-w-0 flex-1 items-center",
            data: {flat_pack_chat_panel_part: "header"}
          ) do
            header.to_s
          end
        end

        def render_right_header_part
          content_tag(
            :div,
            class: right_part_classes(right_header_visibility),
            data: {flat_pack_chat_panel_part: "right-header"}
          ) do
            right_header.to_s
          end
        end

        def render_right_header_mobile_part
          content_tag(
            :div,
            class: right_part_classes("flex sm:hidden"),
            data: {flat_pack_chat_panel_part: "right-header-mobile"}
          ) do
            right_header_mobile.to_s
          end
        end

        # Shared right-part base, plus visibility. A part with no header also gets ml-auto.
        # "flex" "hidden sm:flex" "flex sm:hidden" "ml-auto" "sm:hidden"
        # "ml-auto flex shrink-0 w-min items-center justify-end"
        # "flex shrink-0 w-min items-center justify-end"
        # "ml-auto hidden sm:flex shrink-0 w-min items-center justify-end"
        # "hidden sm:flex shrink-0 w-min items-center justify-end"
        # "ml-auto flex sm:hidden shrink-0 w-min items-center justify-end"
        # "flex sm:hidden shrink-0 w-min items-center justify-end"
        def right_part_classes(visibility)
          [("ml-auto" unless header?), visibility, RIGHT_PART_BASE].compact.join(" ")
        end

        def right_header_visibility
          return "hidden sm:flex" if right_header_mobile?

          "flex"
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

        # "flex items-center" "sm:hidden"
        def split_header_classes
          classes("flex items-center", *header_chrome_classes, mobile_only_row_classes)
        end

        # A lone mobile part has nothing to show at sm and up, so the chrome hides with it.
        def mobile_only_row_classes
          return "sm:hidden" if right_header_mobile? && !header? && !right_header?

          nil
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
