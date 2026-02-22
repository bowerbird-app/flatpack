# frozen_string_literal: true

module FlatPack
  module Chat
    module Composer
      class Component < FlatPack::BaseComponent
        renders_one :textarea
        renders_one :actions
        renders_one :attachments

        def initialize(**system_arguments)
          super(**system_arguments)
        end

        def call
          content_tag(:div, **composer_attributes) do
            safe_join([
              render_attachments_section,
              content_tag(:div, class: "flex items-end gap-2") do
                safe_join([
                  render_textarea_section,
                  render_actions_section
                ])
              end
            ].compact)
          end
        end

        private

        def render_textarea_section
          content_tag(:div, class: "flex-1 min-w-0") do
            if textarea?
              textarea
            else
              render_default_textarea
            end
          end
        end

        def render_default_textarea
          render FlatPack::Chat::Textarea::Component.new(
            placeholder: "Type a message...",
            autogrow: true,
            submit_on_enter: true
          )
        end

        def render_actions_section
          if actions?
            actions
          else
            render_default_actions
          end
        end

        def render_default_actions
          render FlatPack::Chat::SendButton::Component.new
        end

        def render_attachments_section
          return unless attachments?

          content_tag(:div, class: "mb-2") do
            attachments
          end
        end

        def composer_attributes
          merge_attributes(
            class: composer_classes
          )
        end

        def composer_classes
          classes(
            "border-t border-[var(--chat-composer-border-color)]",
            "bg-[var(--chat-composer-background-color)]",
            "p-4"
          )
        end
      end
    end
  end
end
