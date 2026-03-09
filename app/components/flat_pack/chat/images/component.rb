# frozen_string_literal: true

module FlatPack
  module Chat
    module Images
      class Component < FlatPack::BaseComponent
        DEFAULT_STATE = :sent
        DEFAULT_ASPECT_RATIO = "4/3"
        STATES = {
          sent: "sent",
          sending: "sending",
          failed: "failed",
          read: "read"
        }.freeze

        def initialize(
          carousel:,
          direction: :incoming,
          state: DEFAULT_STATE,
          timestamp: nil,
          edited: false,
          body: nil,
          reveal_actions: false,
          **system_arguments
        )
          super(**system_arguments)
          @message_system_arguments = @system_arguments.deep_dup
          @carousel = normalize_carousel(carousel)
          @direction = direction.to_sym
          @state = normalize_state(state)
          @timestamp = timestamp
          @edited = edited
          @body = body
          @reveal_actions = reveal_actions

          validate_direction!
        end

        def call
          render message_component_class.new(**message_component_arguments.merge(@message_system_arguments)) do |message|
            message.with_media_attachment do
              render FlatPack::Carousel::Component.new(**@carousel)
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

        def normalize_carousel(carousel)
          payload = carousel.respond_to?(:to_h) ? carousel.to_h.symbolize_keys : {}
          slides = Array(payload[:slides]).filter_map { |slide| normalize_slide(slide) }

          raise ArgumentError, "carousel must include at least one valid slide" if slides.empty?

          defaults = {
            slides: slides,
            show_controls: slides.length > 1,
            show_indicators: slides.length > 1,
            show_thumbs: slides.length > 1,
            show_captions: false,
            aspect_ratio: DEFAULT_ASPECT_RATIO,
            aria_label: default_aria_label
          }

          defaults.merge(payload.except(:slides)).tap do |normalized|
            normalized[:slides] = slides
          end
        end

        def normalize_slide(slide)
          payload = slide.respond_to?(:to_h) ? slide.to_h.symbolize_keys : {}
          return nil if payload.empty?

          return payload if payload[:src].present? || payload[:html].present? || payload[:poster].present?

          image_src = payload[:src].presence || payload[:href].presence || payload[:thumbnail_url].presence
          return nil unless image_src.present?

          {
            type: :image,
            src: image_src,
            thumb_src: payload[:thumbnail_url].presence,
            lightbox: payload.key?(:lightbox) ? payload[:lightbox] : true
          }.compact
        end

        def default_aria_label
          (@direction == :outgoing) ? "Outgoing chat images" : "Incoming chat images"
        end

        def message_component_class
          (@direction == :outgoing) ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
        end

        def message_component_arguments
          arguments = {
            state: @state
          }

          if @reveal_actions
            arguments[:timestamp] = @timestamp
            arguments[:reveal_actions] = true
          end

          arguments
        end

        def normalize_state(value)
          state = value.to_sym
          return state if STATES.key?(state)

          DEFAULT_STATE
        rescue NoMethodError
          DEFAULT_STATE
        end

        def validate_direction!
          return if %i[incoming outgoing].include?(@direction)

          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: incoming, outgoing"
        end
      end
    end
  end
end
