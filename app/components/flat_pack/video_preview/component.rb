# frozen_string_literal: true

module FlatPack
  module VideoPreview
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-video-preview" "relative" "w-full" "max-w-full" "overflow-hidden" "rounded-[var(--radius-lg)]"
      # "bg-[var(--surface-muted-background-color)]" "aspect-[16/9]" "aspect-[4/3]" "aspect-square"
      # "absolute" "inset-0" "h-full" "w-full" "cursor-pointer"
      # "[&>img]:block" "[&>img]:h-full" "[&>img]:w-full" "[&>img]:max-w-none" "[&>img]:object-cover"
      # "fp-video-preview__play" "fp-hit-target" "inline-flex" "h-16" "w-16" "shrink-0" "items-center" "justify-center"
      # "rounded-full" "border" "border-[var(--button-default-border-color)]"
      # "bg-[var(--button-default-background-color)]" "text-[var(--button-default-text-color)]"
      # "shadow-md" "transition-[background-color,box-shadow,transform]"
      # "duration-[var(--duration-fast)]" "ease-[var(--easing-standard)]"
      # "hover:bg-[var(--button-default-hover-background-color)]" "hover:shadow-lg"
      # "active:translate-y-px" "active:shadow-sm"
      # "motion-reduce:transform-none" "motion-reduce:transition-none"
      # "focus-visible:outline-none" "focus-visible:ring-2" "focus-visible:ring-inset"
      # "focus-visible:ring-[var(--button-focus-ring-color)]" "focus-visible:ring-offset-2"
      # "focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]"
      # "translate-x-0.5"

      class Item < ViewComponent::Base
        attr_reader :placement, :inset, :system_arguments

        def initialize(placement: :top_left, inset: :md, **system_arguments)
          @placement = placement
          @inset = inset
          @system_arguments = system_arguments
        end

        def call
          content
        end
      end

      renders_one :media
      renders_one :player
      renders_many :items, Item

      def initialize(label:, aspect_ratio: "16/9", **system_arguments)
        super(**system_arguments)
        @label = label
        @aspect_ratio = normalize_aspect_ratio(aspect_ratio)

        validate_label!
      end

      def before_render
        raise ArgumentError, "media slot is required" unless media?
        raise ArgumentError, "player slot is required" unless player?

        super
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([poster_frame, player_template])
        end
      end

      private

      def root_attributes
        merge_attributes(
          class: frame_classes,
          data: {
            controller: "flat-pack--video-preview",
            action: "click->flat-pack--video-preview#play keydown->flat-pack--video-preview#play"
          }
        )
      end

      def frame_classes
        [
          "fp-video-preview",
          "relative",
          "w-full",
          "max-w-full",
          "overflow-hidden",
          "rounded-[var(--radius-lg)]",
          "bg-[var(--surface-muted-background-color)]",
          aspect_class
        ].join(" ")
      end

      def aspect_class
        case @aspect_ratio
        when "16/9" then "aspect-[16/9]"
        when "4/3" then "aspect-[4/3]"
        when "1/1" then "aspect-square"
        else "aspect-[#{@aspect_ratio}]"
        end
      end

      def poster_frame
        content_tag(:div, class: "absolute inset-0 h-full w-full cursor-pointer", data: {flat_pack__video_preview_target: "poster"}) do
          render(FlatPack::Overlay::Component.new(class: "h-full w-full")) do |overlay|
            overlay.with_media { media_frame }
            overlay.with_item(placement: :center) { play_button }
            forward_items(overlay)
          end
        end
      end

      def media_frame
        content_tag(
          :div,
          media,
          class: "absolute inset-0 h-full w-full [&>img]:block [&>img]:h-full [&>img]:w-full [&>img]:max-w-none [&>img]:object-cover"
        )
      end

      def forward_items(overlay)
        items.each do |item|
          overlay.with_item(placement: item.placement, inset: item.inset, **item.system_arguments) do
            item.to_s
          end
        end
      end

      def play_button
        content_tag(
          :button,
          type: "button",
          class: play_button_classes,
          aria: {label: @label},
          data: {flat_pack__video_preview_target: "play"}
        ) do
          render FlatPack::Shared::IconComponent.new(name: :play, variant: :solid, size: :xl, class: "translate-x-0.5")
        end
      end

      def play_button_classes
        [
          "fp-video-preview__play",
          "fp-hit-target",
          "inline-flex",
          "h-16",
          "w-16",
          "shrink-0",
          "items-center",
          "justify-center",
          "rounded-full",
          "border",
          "border-[var(--button-default-border-color)]",
          "bg-[var(--button-default-background-color)]",
          "text-[var(--button-default-text-color)]",
          "shadow-md",
          "cursor-pointer",
          "transition-[background-color,box-shadow,transform]",
          "duration-[var(--duration-fast)]",
          "ease-[var(--easing-standard)]",
          "hover:bg-[var(--button-default-hover-background-color)]",
          "hover:shadow-lg",
          "active:translate-y-px",
          "active:shadow-sm",
          "motion-reduce:transform-none",
          "motion-reduce:transition-none",
          "focus-visible:outline-none",
          "focus-visible:ring-2",
          "focus-visible:ring-inset",
          "focus-visible:ring-[var(--button-focus-ring-color)]",
          "focus-visible:ring-offset-2",
          "focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]"
        ].join(" ")
      end

      def player_template
        content_tag(:template, player, data: {flat_pack__video_preview_target: "player"})
      end

      def normalize_aspect_ratio(value)
        ratio = value.to_s.strip.delete(" ")

        unless ratio.match?(/\A\d+(?:\.\d+)?\/\d+(?:\.\d+)?\z/)
          raise ArgumentError, "aspect_ratio must look like \"16/9\""
        end

        ratio
      end

      def validate_label!
        unless @label.is_a?(String)
          raise ArgumentError, "label must be a String"
        end

        return if @label.strip.present?

        raise ArgumentError, "label is required"
      end
    end
  end
end
