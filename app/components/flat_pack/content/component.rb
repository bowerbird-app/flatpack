# frozen_string_literal: true

module FlatPack
  module Content
    class Component < FlatPack::BaseComponent
      def call
        raise ArgumentError, "content is required" if content.blank?

        content_tag(:div, content, **container_attributes)
      end

      private

      def container_attributes
        merge_attributes(class: "fp-content")
      end
    end
  end
end
