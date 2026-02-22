# frozen_string_literal: true

module FlatPack
  module Chat
    module Panel
      class Component < FlatPack::BaseComponent
        renders_one :header
        renders_one :messages
        renders_one :composer

        def initialize(**system_arguments)
          super(**system_arguments)
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
            header
          end
        end

        def render_messages_section
          messages
        end

        def render_composer_section
          composer
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
            "border-b border-border",
            "bg-background"
          )
        end
      end
    end
  end
end
