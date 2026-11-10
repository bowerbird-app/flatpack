# frozen_string_literal: true

module FlatPack
  module Chat
    module SentAt
      class Component < FlatPack::BaseComponent
        def initialize(timestamp:, **system_arguments)
          super(**system_arguments)
          @timestamp = timestamp
        end

        def call
          content_tag(:span, sent_copy, **merge_attributes(class: "text-xs text-[var(--chat-message-meta-color)]"))
        end

        private

        def sent_copy
          fp_t("chat.sent_at", time: formatted_timestamp)
        end

        def formatted_timestamp
          return @timestamp.to_s unless @timestamp.respond_to?(:strftime)

          @timestamp.strftime(fp_t("chat.timestamp_format")).strip
        end
      end
    end
  end
end
