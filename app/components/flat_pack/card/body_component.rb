# frozen_string_literal: true

module FlatPack
  module Card
    class BodyComponent < ViewComponent::Base
      def initialize(**system_arguments)
        @system_arguments = system_arguments
      end

      def call
        content_tag(:div, content, class: "px-6 py-4 flex-1", **@system_arguments)
      end
    end
  end
end
