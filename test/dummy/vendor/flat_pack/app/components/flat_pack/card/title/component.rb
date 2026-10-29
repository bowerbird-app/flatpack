# frozen_string_literal: true

module FlatPack
  module Card
    module Title
      class Component < ViewComponent::Base
        TAGS = %i[h1 h2 h3].freeze

        def initialize(prefix: nil, as: :h2, **system_arguments)
          @prefix = prefix.presence
          @as = as.to_sym
          @system_arguments = system_arguments
          validate_as!
        end

        def call
          content_tag(@as, **merged_system_arguments(title_classes)) do
            safe_join([prefix_node, content].compact)
          end
        end

        private

        def prefix_node
          return if @prefix.blank?

          content_tag(:span, @prefix, data: {fp_card_part: "title-prefix"})
        end

        def merged_system_arguments(default_classes)
          @system_arguments.merge(
            class: class_names(default_classes, @system_arguments[:class])
          )
        end

        def title_classes
          "fp-card__title fp-text-balance"
        end

        def validate_as!
          return if TAGS.include?(@as)

          raise ArgumentError, "Invalid as: #{@as}. Must be one of: #{TAGS.join(", ")}"
        end
      end
    end
  end
end
