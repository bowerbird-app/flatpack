# frozen_string_literal: true

module FlatPack
  module Masonry
    class Item < FlatPack::BaseComponent
      def call
        content_tag(:div, content, **item_attributes)
      end

      private

      def item_attributes
        merge_attributes(
          class: "fp-masonry__item",
          data: {flat_pack__masonry_target: "item"}
        )
      end
    end
  end
end
