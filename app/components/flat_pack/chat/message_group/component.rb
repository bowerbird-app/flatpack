# frozen_string_literal: true

module FlatPack
  module Chat
    module MessageGroup
      class Component < FlatPack::BaseComponent
        renders_one :avatar
        renders_many :messages

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "flex-row" "flex-row-reverse"
        DIRECTIONS = {
          incoming: "flex-row",
          outgoing: "flex-row-reverse"
        }.freeze

        def initialize(
          direction: :incoming,
          show_avatar: true,
          show_name: false,
          sender_name: nil,
          **system_arguments
        )
          super(**system_arguments)
          @direction = direction.to_sym
          @show_avatar = show_avatar
          @show_name = show_name
          @sender_name = sender_name

          validate_direction!
        end

        def call
          content_tag(:div, **group_attributes) do
            safe_join([
              render_avatar_section,
              render_messages_section
            ])
          end
        end

        private

        def render_avatar_section
          return unless @show_avatar

          content_tag(:div, class: "flex-shrink-0 #{@direction == :incoming ? "mr-3" : "ml-3"}") do
            if avatar?
              avatar
            else
              render_default_avatar
            end
          end
        end

        def render_default_avatar
          # Default avatar placeholder
          content_tag(:div, class: "h-8 w-8 rounded-full bg-muted flex items-center justify-center") do
            content_tag(:span, class: "text-xs font-medium text-muted-foreground") do
              (@sender_name&.first || "?").upcase
            end
          end
        end

        def render_messages_section
          content_tag(:div, class: messages_container_classes) do
            safe_join([
              render_sender_name,
              render_messages_list
            ].compact)
          end
        end

        def render_sender_name
          return unless @show_name && @sender_name.present?

          content_tag(:div, class: name_classes) do
            @sender_name
          end
        end

        def render_messages_list
          content_tag(:div, class: "space-y-1") do
            safe_join(messages)
          end
        end

        def group_attributes
          merge_attributes(
            class: group_classes
          )
        end

        def group_classes
          classes(
            "flex items-start gap-0",
            DIRECTIONS.fetch(@direction)
          )
        end

        def messages_container_classes
          classes(
            "flex-1 min-w-0",
            "space-y-1"
          )
        end

        def name_classes
          classes(
            "text-sm font-medium text-foreground mb-1",
            @direction == :outgoing ? "text-right" : "text-left"
          )
        end

        def validate_direction!
          return if DIRECTIONS.key?(@direction)
          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: #{DIRECTIONS.keys.join(", ")}"
        end
      end
    end
  end
end
