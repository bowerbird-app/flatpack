# frozen_string_literal: true

module FlatPack
  module Chat
    module ImageMessage
      class Component < FlatPack::BaseComponent
        def initialize(
          direction: :incoming,
          state: :sent,
          timestamp: nil,
          edited: false,
          image_name:,
          thumbnail_url:,
          image_href: nil,
          body: nil,
          reveal_actions: false,
          **system_arguments
        )
          super(**system_arguments)
          @direction = direction.to_sym
          @state = state.to_sym
          @timestamp = timestamp
          @edited = edited
          @image_name = image_name
          @thumbnail_url = thumbnail_url
          @image_href = image_href
          @body = body
          @reveal_actions = reveal_actions

          validate_direction!
        end

        def call
          render message_component_class.new(**message_component_arguments) do |message|
            message.with_attachment do
              render FlatPack::Chat::Attachment::Component.new(
                type: :image,
                name: @image_name,
                thumbnail_url: @thumbnail_url,
                href: @image_href
              )
            end

            message.with_meta do
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
          @direction == :outgoing ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
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
