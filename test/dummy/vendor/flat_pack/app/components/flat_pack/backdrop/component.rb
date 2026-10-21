# frozen_string_literal: true

module FlatPack
  module Backdrop
    # Blurred media, tint, and fill behind whatever the host puts in the block.
    # The host owns the content's type, colour, and spacing.
    class Component < FlatPack::BaseComponent
      renders_one :media

      def call
        body = content
        content_tag(:div, **root_attributes(body)) do
          safe_join([render_layers, body.presence].compact)
        end
      end

      private

      def root_attributes(body)
        extra = {class: "fp-backdrop"}
        extra[:aria] = {hidden: true} if body.blank?
        merge_attributes(**extra)
      end

      def render_layers
        return unless media?

        content_tag(:div, class: "fp-backdrop-layers", aria: {hidden: true}) do
          safe_join([
            content_tag(:div, media, class: "fp-backdrop-media"),
            content_tag(:div, "", class: "fp-backdrop-tint")
          ])
        end
      end
    end
  end
end
