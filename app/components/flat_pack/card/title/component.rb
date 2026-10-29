# frozen_string_literal: true

module FlatPack
  module Card
    module Title
      # Heading supplies the tag, the balance class, and tight leading.
      # Size, weight, and colour stay on .fp-card__title. Featured defaults
      # are on :where(.fp-card--featured), so a card or ancestor variable wins.
      class Component < FlatPack::Heading::Component
        def initialize(prefix: nil, level: :h2, **system_arguments)
          @prefix = prefix.presence
          super(level: level, size: :"2xl", weight: :semibold, style: :default, **system_arguments)
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
      end
    end
  end
end
