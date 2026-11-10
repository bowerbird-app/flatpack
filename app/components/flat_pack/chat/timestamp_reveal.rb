# frozen_string_literal: true

module FlatPack
  module Chat
    module TimestampReveal
      WRAPPER_CLASS = "fp-chat-timestamp-reveal"
      TIME_CLASS = "fp-chat-timestamp"
      CONTROLLER_ID = "flat-pack--chat-timestamp-reveal"

      def timestamp_reveal_enabled?
        @reveal_timestamp && !@reveal_actions
      end

      def timestamp_reveal_attributes(class_name, data)
        return {class: class_name, data: data} unless timestamp_reveal_enabled?

        {
          class: classes(class_name, WRAPPER_CLASS),
          data: data.merge(
            controller: CONTROLLER_ID,
            action: "click->#{CONTROLLER_ID}#toggle"
          ),
          tabindex: 0
        }
      end

      def revealed_timestamp_tag
        return unless timestamp_reveal_enabled? && @timestamp.present?

        content_tag(
          :span,
          formatted_timestamp,
          class: "#{TIME_CLASS} text-xs text-[var(--chat-message-meta-color)]"
        )
      end
    end
  end
end
