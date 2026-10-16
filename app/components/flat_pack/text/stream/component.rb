# frozen_string_literal: true

module FlatPack
  module Text
    module Stream
      class Component < FlatPack::BaseComponent
        TAGS = FlatPack::Motion::TAGS

        def initialize(text:, tag: :p, **system_arguments)
          super(**system_arguments)
          validate_text_option!(text, name: :text)
          @text = text.to_s
          @tag = tag
          raise ArgumentError, "text is required" if @text.blank?
        end

        def call
          content_tag(root_tag, **root_attributes) do
            safe_join([
              content_tag(:span, @text, class: "fp-text-stream__sizer", aria: {hidden: true}),
              content_tag(:span, @text, class: "fp-text-stream__source", data: {flat_pack__text_stream_target: "source"}),
              content_tag(
                :span,
                safe_join([
                  content_tag(:span, "", class: "fp-text-stream__typed", data: {flat_pack__text_stream_target: "typed"}),
                  content_tag(:span, "", class: "fp-text-stream__caret", data: {flat_pack__text_stream_target: "caret"}, aria: {hidden: true})
                ]),
                class: "fp-text-stream__live",
                hidden: true,
                aria: {hidden: true},
                data: {flat_pack__text_stream_target: "live"}
              )
            ])
          end
        end

        private

        def root_tag
          name = @tag.to_sym
          return name if TAGS.include?(name)

          raise ArgumentError, "Invalid tag: #{@tag}. Must be one of: #{TAGS.join(", ")}"
        end

        def root_attributes
          merge_attributes(
            class: "fp-text-stream",
            data: {controller: "flat-pack--text-stream"}
          )
        end
      end
    end
  end
end
