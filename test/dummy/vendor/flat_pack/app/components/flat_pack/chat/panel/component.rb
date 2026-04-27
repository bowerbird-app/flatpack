# frozen_string_literal: true

module FlatPack
  module Chat
    module Panel
      class Component < FlatPack::BaseComponent
        renders_one :header
        renders_one :messages
        renders_one :composer

        undef_method :with_header, :with_header_content
        undef_method :with_messages, :with_messages_content
        undef_method :with_composer, :with_composer_content

        def initialize(**system_arguments)
          super
        end

        def header(*args, **kwargs, &block)
          return get_slot(:header) if args.empty? && kwargs.empty? && !block_given?

          set_slot(:header, nil, *args, **kwargs, &block)
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
              (render_header_section if header?),
              (render_messages_section if messages?),
              (render_composer_section if composer?)
            ].compact)
          end
        end

        private

        def render_header_section
          content_tag(:div, class: header_classes) do
            header.to_s
          end
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
            "h-full",
            "overflow-hidden"
          )
        end

        def header_classes
          classes(
            "flex-shrink-0",
            "border-b border-[var(--chat-header-border-color)]",
            "bg-[var(--chat-header-background-color)]"
          )
        end
      end
    end
  end
end
