# frozen_string_literal: true

module FlatPack
  module Card
    module Media
      class Component < ViewComponent::Base
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "aspect-[16/9]" "aspect-[4/3]" "aspect-square"
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "px-4 pt-4" "px-6 pt-6" "px-8 pt-8"
        PADDINGS = {
          none: "",
          sm: "px-4 pt-4",
          md: "px-6 pt-6",
          lg: "px-8 pt-8"
        }.freeze

        def initialize(aspect_ratio: nil, padding: :md, **system_arguments)
          @aspect_ratio = aspect_ratio
          @padding = padding.to_sym
          @system_arguments = system_arguments

          validate_padding!
        end

        def call
          content_tag(:div, content, class: media_classes, **@system_arguments)
        end

        private

        def media_classes
          classes = ["overflow-hidden", padding_classes]

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

        def padding_classes
          PADDINGS.fetch(@padding)
        end

        def validate_padding!
          return if PADDINGS.key?(@padding)

          raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
        end
      end
    end
  end
end
