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
        # "px-[var(--card-padding-sm)]" "pt-[var(--card-padding-sm)]" "px-[var(--card-padding-md)]" "pt-[var(--card-padding-md)]" "px-[var(--card-padding-lg)]" "pt-[var(--card-padding-lg)]"
        # "relative" "group/media"
        # "opacity-100" "focus-within:opacity-100" "[@media(hover:hover)]:opacity-0"
        # "[@media(hover:hover)]:group-hover/media:opacity-100"
        # "motion-safe:transition-opacity" "motion-safe:duration-[var(--duration-fast)]"
        # "motion-safe:ease-[var(--easing-standard)]" "motion-reduce:transition-none"
        PADDINGS = {
          none: "",
          sm: "px-[var(--card-padding-sm)] pt-[var(--card-padding-sm)]",
          md: "px-[var(--card-padding-md)] pt-[var(--card-padding-md)]",
          lg: "px-[var(--card-padding-lg)] pt-[var(--card-padding-lg)]"
        }.freeze

        HOVER_REVEAL_CLASSES = [
          "opacity-100",
          "focus-within:opacity-100",
          "[@media(hover:hover)]:opacity-0",
          "[@media(hover:hover)]:group-hover/media:opacity-100",
          "motion-safe:transition-opacity",
          "motion-safe:duration-[var(--duration-fast)]",
          "motion-safe:ease-[var(--easing-standard)]",
          "motion-reduce:transition-none"
        ].join(" ").freeze

        # Nested overlay for a control on the photo. Named hover_actions so it
        # does not collide with a later Card-level actions slot.
        class HoverActions < ViewComponent::Base
          attr_reader :placement, :inset, :system_arguments

          def initialize(placement: :top_right, inset: :sm, **system_arguments)
            @placement = placement
            @inset = inset
            @system_arguments = system_arguments
          end

          def call
            arguments = @system_arguments.dup
            extra_class = arguments.delete(:class)
            extra_data = (arguments.delete(:data) || {}).dup
            render(
              FlatPack::Overlay::Item.new(
                placement: @placement,
                inset: @inset,
                class: class_names(HOVER_REVEAL_CLASSES, extra_class),
                data: extra_data.merge(fp_card_media_part: "hover-actions"),
                **arguments
              )
            ) { content }
          end
        end

        renders_one :hover_actions_slot, HoverActions
        undef_method :with_hover_actions_slot, :with_hover_actions_slot_content

        def hover_actions(**args, &block)
          return hover_actions_slot if args.empty? && !block

          __vc_set_slot(:hover_actions_slot, nil, **args, &block)
        end

        def hover_actions?
          hover_actions_slot?
        end

        def initialize(aspect_ratio: nil, padding: :md, cover: false, **system_arguments)
          @aspect_ratio = aspect_ratio
          @padding = padding.to_sym
          @cover = cover
          @system_arguments = system_arguments

          validate_padding!
          validate_cover!
        end

        # Featured cards pass cover: true. The block can call this so the slot,
        # not thread state, sets FlatPack::Media cover:. A cover: on this call
        # wins, so the host can pass cover: false and keep h-auto.
        def image(**arguments)
          cover = arguments.key?(:cover) ? arguments.delete(:cover) : @cover
          render(FlatPack::Media::Component.new(**arguments, cover: cover))
        end

        def call
          content_tag(:div, inner_content, **merged_system_arguments(media_classes))
        end

        private

        def inner_content
          return content unless hover_actions?

          safe_join([content, hover_actions].compact)
        end

        def merged_system_arguments(default_classes)
          @system_arguments.merge(
            class: class_names(default_classes, @system_arguments[:class])
          )
        end

        def media_classes
          classes = ["overflow-hidden", padding_classes]
          classes.concat(%w[relative group/media]) if hover_actions?

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

        def validate_cover!
          return if @cover == true || @cover == false

          raise ArgumentError, "Invalid cover: #{@cover.inspect}. Must be true or false."
        end
      end
    end
  end
end
