# frozen_string_literal: true

module FlatPack
  module Card
    class MediaComponent < ViewComponent::Base
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "aspect-[16/9]" "aspect-[4/3]" "aspect-square"
      def initialize(aspect_ratio: nil, **system_arguments)
        @aspect_ratio = aspect_ratio
        @system_arguments = system_arguments
      end

      def call
        content_tag(:div, content, class: media_classes, **@system_arguments)
      end

      private

      def media_classes
        classes = ["overflow-hidden"]

        if @aspect_ratio
          classes << case @aspect_ratio
          when "16/9" then "aspect-[16/9]"
          when "4/3" then "aspect-[4/3]"
          when "1/1" then "aspect-square"
          else "aspect-[#{@aspect_ratio}]"
          end
        end

        classes.join(" ")
      end
    end
  end
end
