# frozen_string_literal: true

module FlatPack
  module Chat
    module ImageMessage
      class Component < FlatPack::BaseComponent
        def initialize(
          image_name:, thumbnail_url:, direction: :incoming,
          state: :sent,
          timestamp: nil,
          edited: false,
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
          render FlatPack::Chat::Images::Component.new(
            direction: @direction,
            state: @state,
            timestamp: @timestamp,
            edited: @edited,
            body: @body,
            reveal_actions: @reveal_actions,
            carousel: {
              slides: [
                {
                  type: :image,
                  src: @image_href.presence || @thumbnail_url,
                  thumb_src: @thumbnail_url,
                  alt: @image_name,
                  lightbox: true
                }
              ],
              show_controls: true,
              show_indicators: false,
              show_thumbs: false,
              show_captions: false,
              aspect_ratio: "4/3"
            }
          )
        end

        private

        def validate_direction!
          return if [:incoming, :outgoing].include?(@direction)

          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: incoming, outgoing"
        end
      end
    end
  end
end
