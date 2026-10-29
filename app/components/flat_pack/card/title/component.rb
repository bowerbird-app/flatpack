# frozen_string_literal: true

module FlatPack
  module Card
    module Title
      # Heading supplies the tag, the balance class, and tight leading.
      # Size, weight, and colour stay on .fp-card__title so a featured card
      # can set --card-title-* without a parent rule overriding the heading.
      class Component < FlatPack::Heading::Component
        TAGS = %i[h1 h2 h3].freeze

        def initialize(prefix: nil, as: :h2, **system_arguments)
          @prefix = prefix.presence
          @as = as.to_sym
          validate_as!
          super(level: @as, size: :"2xl", weight: :semibold, style: :default, **system_arguments)
        end

        def call
          content_tag(@level, safe_join([prefix_node, title_text].compact), **heading_attributes)
        end

        private

        def prefix_node
          return if @prefix.blank?

          content_tag(:span, @prefix, data: {fp_card_part: "title-prefix"})
        end

        def title_text
          text = content.presence || @text
          return text if text.present?

          raise ArgumentError, "text is required" if @prefix.blank?

          nil
        end

        def heading_classes
          classes(
            "fp-heading",
            "fp-card__title",
            "fp-text-balance",
            "leading-tight"
          )
        end

        def validate_as!
          return if TAGS.include?(@as)

          raise ArgumentError, "Invalid as: #{@as}. Must be one of: #{TAGS.join(", ")}"
        end
      end
    end
  end
end
