# frozen_string_literal: true

module FlatPack
  module Chat
    module FileMessage
      class Component < FlatPack::BaseComponent
        def initialize(
          file_name:, direction: :incoming,
          state: :sent,
          timestamp: nil,
          edited: false,
          file_meta: nil,
          file_href: nil,
          body: nil,
          reveal_actions: false,
          **system_arguments
        )
          super(**system_arguments)
          @direction = direction.to_sym
          @state = state.to_sym
          @timestamp = timestamp
          @edited = edited
          @file_name = file_name
          @file_meta = file_meta
          @file_href = file_href
          @body = body
          @reveal_actions = reveal_actions

          validate_direction!
        end

        def call
          render message_component_class.new(**message_component_arguments) do |message|
            message.attachment do
              render FlatPack::Chat::Attachment::Component.new(
                type: :file,
                name: @file_name,
                meta: @file_meta,
                href: @file_href
              )
            end

            message.meta do
              render FlatPack::Chat::MessageMeta::Component.new(
                timestamp: @timestamp,
                state: @state,
                edited: @edited
              )
            end

            @body.presence || " "
          end
        end

        private

        def message_component_class
          (@direction == :outgoing) ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
        end

        def message_component_arguments
          base_arguments = {
            state: @state
          }

          if @direction == :outgoing
            base_arguments[:timestamp] = @timestamp
            base_arguments[:reveal_actions] = @reveal_actions
          end

          base_arguments
        end

        def validate_direction!
          return if [:incoming, :outgoing].include?(@direction)

          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: incoming, outgoing"
        end
      end
    end
  end
end
