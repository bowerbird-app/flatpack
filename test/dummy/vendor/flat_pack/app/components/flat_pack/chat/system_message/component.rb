# frozen_string_literal: true

module FlatPack
  module Chat
    module SystemMessage
      class Component < FlatPack::BaseComponent
        def call
          content_tag(:div, **message_attributes) do
            content_tag(:div, class: "text-center py-1") do
              content
            end
          end
        end

        private

        def message_attributes
          merge_attributes(
            class: "flex justify-center w-full bg-transparent text-[var(--chat-message-system-text-color)] text-xs italic",
            data: {
              flat_pack_chat_group_break: true
            }
          )
        end
      end
    end
  end
end
