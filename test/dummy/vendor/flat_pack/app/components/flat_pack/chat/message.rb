# frozen_string_literal: true

module FlatPack
  module Chat
    module Message
      class Component < FlatPack::BaseComponent
        DIRECTIONS = %i[incoming outgoing].freeze
        VARIANTS = %i[default system].freeze
        STATES = %i[sent sending failed read].freeze

        renders_many :attachments
        renders_one :meta

        alias_method :meta_slot, :meta

        undef_method :with_attachment, :with_attachment_content,
          :with_meta, :with_meta_content

        def attachment(*args, **kwargs, &block)
          set_slot(:attachments, nil, *args, **kwargs, &block)
        end

        def meta(*args, **kwargs, &block)
          return meta_slot if args.empty? && kwargs.empty? && !block_given?

          set_slot(:meta, nil, *args, **kwargs, &block)
        end

        def initialize(
          direction: :incoming,
          variant: :default,
          state: :sent,
          timestamp: nil,
          **system_arguments
        )
          super(**system_arguments)
          @direction = direction.to_sym
          @variant = variant.to_sym
          @state = state.to_sym
          @timestamp = timestamp

          validate_direction!
          validate_variant!
          validate_state!
        end

        def call
          return render_system_message if @variant == :system

          content_tag(:div, **message_attributes) do
            content_tag(:div, class: body_wrapper_classes) do
              safe_join([
                render_bubble,
                render_meta_section
              ].compact)
            end
          end
        end

        private

        def render_system_message
          content_tag(:div, **merge_attributes(class: "flex justify-center w-full bg-transparent text-[var(--chat-message-system-text-color)] text-xs italic")) do
            content_tag(:div, class: "text-center py-1") { content }
          end
        end

        def message_attributes
          merge_attributes(
            class: ((@direction == :outgoing) ? "flex justify-end" : "flex justify-start"),
            data: {chat_message_state: @state}
          )
        end

        def body_wrapper_classes
          (@direction == :outgoing) ? "flex flex-col items-end" : "flex flex-col items-start"
        end

        def render_bubble
          content_tag(:div, class: bubble_classes) do
            safe_join([
              content_tag(:div, content, class: "break-words whitespace-pre-line"),
              render_attachments
            ].compact)
          end
        end

        def render_attachments
          return unless attachments?

          content_tag(:div, class: "mt-2 space-y-2") { safe_join(attachments) }
        end

        def render_meta_section
          return unless meta? || @timestamp.present?

          content_tag(:div, class: meta_wrapper_classes) do
            if meta?
              meta.to_s
            else
              content_tag(:span, formatted_timestamp, class: "text-xs text-[var(--chat-message-meta-color)]")
            end
          end
        end

        def meta_wrapper_classes
          if @direction == :outgoing
            "mt-1 w-full flex justify-end [--chat-message-meta-color:var(--chat-message-outgoing-meta-color)] [--chat-read-receipt-color:var(--chat-message-outgoing-read-receipt-color)]"
          else
            "mt-1 [--chat-message-meta-color:var(--chat-message-incoming-meta-color)] [--chat-read-receipt-color:var(--chat-message-incoming-read-receipt-color)]"
          end
        end

        def bubble_classes
          classes(
            "relative px-4 py-2 rounded-2xl max-w-[75%] sm:max-w-[500px] shadow-sm",
            ((@direction == :outgoing) ? "bg-[var(--chat-message-outgoing-background-color)] text-[var(--chat-message-outgoing-text-color)]" : "bg-[var(--chat-message-incoming-background-color)] text-[var(--chat-message-incoming-text-color)]"),
            state_classes
          )
        end

        def state_classes
          case @state
          when :sending
            "opacity-60"
          when :failed
            "opacity-50 border-2 border-[var(--chat-message-failed-color)]"
          end
        end

        def formatted_timestamp
          return @timestamp.to_s unless @timestamp.respond_to?(:strftime)

          @timestamp.strftime("%l:%M %p").strip
        end

        def validate_direction!
          return if DIRECTIONS.include?(@direction)

          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: #{DIRECTIONS.join(", ")}"
        end

        def validate_variant!
          return if VARIANTS.include?(@variant)

          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
        end

        def validate_state!
          return if STATES.include?(@state)

          raise ArgumentError, "Invalid state: #{@state}. Must be one of: #{STATES.join(", ")}"
        end
      end
    end
  end
end
