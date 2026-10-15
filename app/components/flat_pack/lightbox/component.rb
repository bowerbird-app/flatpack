# frozen_string_literal: true

module FlatPack
  module Lightbox
    def self.trigger_data(group:, index: 0)
      {
        flat_pack_lightbox_group: Component.validate_group!(group),
        flat_pack_lightbox_index: Component.normalize_index!(index)
      }
    end

    # The overlay only. Triggers live elsewhere and name this `group`.
    class Component < FlatPack::BaseComponent
      ITEM_TYPES = %i[image video].freeze
      GROUP_PATTERN = /\A[A-Za-z][A-Za-z0-9_-]*\z/

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fixed" "inset-0" "z-50" "m-0" "h-dvh" "max-h-none" "w-full" "max-w-none"
      # "overflow-hidden" "border-0" "bg-transparent" "p-0"
      # "backdrop:bg-[var(--modal-backdrop-color)]" "backdrop:backdrop-blur-[var(--modal-backdrop-blur)]"
      # "fp-overlay-pad" "grid" "h-full" "grid-rows-[auto_minmax(0,1fr)]"
      # "place-self-end" "place-items-center" "justify-self-center" "min-h-0" "max-w-[90vw]"
      # "aspect-square" "w-10" "cursor-pointer" "items-center" "rounded-full"
      # "bg-[var(--carousel-control-background-color)]" "text-[var(--carousel-control-text-color)]"
      # "transition-colors" "duration-[var(--duration-fast)]" "ease-[var(--easing-standard)]"
      # "hover:bg-[var(--carousel-control-hover-background-color)]"
      # "focus-visible:outline-none" "focus-visible:ring-2" "focus-visible:ring-inset" "focus-visible:ring-ring"
      # "motion-reduce:transition-none"

      def self.validate_group!(group)
        value = group.to_s
        return value if value.match?(GROUP_PATTERN)

        raise ArgumentError, "group must start with a letter and contain only letters, numbers, hyphens, or underscores"
      end

      def self.normalize_index!(index)
        value = Integer(index)
        raise ArgumentError, "index must be zero or greater" if value.negative?

        value
      rescue ArgumentError
        raise ArgumentError, "index must be zero or greater"
      end

      def self.boolean!(value, name)
        return value if value == true || value == false

        raise ArgumentError, "#{name} must be true or false"
      end

      def initialize(group:, items:, loop: true, show_count: true)
        super()
        @group = self.class.validate_group!(group)
        @loop = self.class.boolean!(loop, :loop)
        @show_count = self.class.boolean!(show_count, :show_count)
        @items = normalize_items(items)

        raise ArgumentError, "items must include at least one image or video" if @items.empty?
      end

      def call
        content_tag(:dialog, **dialog_attributes) do
          content_tag(:div, class: shell_classes) do
            safe_join([
              render_close_button,
              render_stage
            ])
          end
        end
      end

      private

      def dialog_attributes
        {
          hidden: true,
          class: dialog_classes,
          aria: {label: fp_t("lightbox.label")},
          data: {
            controller: "flat-pack--lightbox",
            flat_pack__lightbox_group_value: @group,
            flat_pack__lightbox_target: "dialog",
            action: dialog_actions
          }
        }
      end

      def dialog_actions
        [
          "click->flat-pack--lightbox#clickBackdrop",
          "cancel->flat-pack--lightbox#cancel",
          "keydown->flat-pack--lightbox#keydown",
          "close->flat-pack--lightbox#closed"
        ].join(" ")
      end

      def dialog_classes
        [
          "fixed inset-0 z-50 m-0 h-dvh max-h-none w-full max-w-none overflow-hidden border-0 bg-transparent p-0",
          "backdrop:bg-[var(--modal-backdrop-color)]",
          "backdrop:backdrop-blur-[var(--modal-backdrop-blur)]"
        ].join(" ")
      end

      def shell_classes
        "fp-overlay-pad grid h-full w-full grid-rows-[auto_minmax(0,1fr)]"
      end

      def render_close_button
        content_tag(:button, type: "button", class: close_classes, aria: {label: fp_t("lightbox.close")}, data: {action: "click->flat-pack--lightbox#close"}) do
          render FlatPack::Shared::IconComponent.new(name: "x-mark", size: :md, class: "pointer-events-none")
        end
      end

      def close_classes
        [
          "place-self-end z-30 flex aspect-square w-10 cursor-pointer items-center justify-center rounded-full",
          "bg-[var(--carousel-control-background-color)] text-[var(--carousel-control-text-color)]",
          "transition-colors duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
          "hover:bg-[var(--carousel-control-hover-background-color)]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          "motion-reduce:transition-none"
        ].join(" ")
      end

      def render_stage
        content_tag(:div, class: stage_classes, data: {flat_pack__lightbox_target: "stage"}) do
          render FlatPack::Carousel::Component.new(**carousel_options)
        end
      end

      def stage_classes
        "grid h-full min-h-0 w-full max-w-[90vw] place-items-center justify-self-center"
      end

      def carousel_options
        {
          slides: carousel_slides,
          loop: @loop,
          show_controls: true,
          show_indicators: false,
          show_thumbs: false,
          show_captions: captions?,
          caption_mode: :below,
          show_border: false,
          show_background: false,
          show_counter: @show_count,
          autoplay: false,
          touch_swipe: true,
          fit: :contain,
          stage: true,
          aria_label: fp_t("lightbox.label")
        }
      end

      def carousel_slides
        @items.map { |item| item.merge(lightbox: false) }
      end

      def captions?
        @items.any? { |item| item[:caption].present? }
      end

      def normalize_items(items)
        Array(items).filter_map.with_index do |item, index|
          normalize_item(item, index)
        end
      end

      def normalize_item(item, index)
        payload = item.respond_to?(:to_h) ? item.to_h.symbolize_keys : {}
        type = item_type!(payload)
        src = FlatPack::AttributeSanitizer.sanitize_url(payload[:src])
        return if src.blank?

        {
          type: type,
          src: src,
          alt: payload[:alt].presence || fp_t("lightbox.item", number: index + 1),
          caption: payload[:caption].to_s,
          poster: FlatPack::AttributeSanitizer.sanitize_url(payload[:poster]),
          controls: payload.fetch(:controls, true),
          muted: payload.fetch(:muted, false),
          video_loop: payload.fetch(:video_loop, false),
          playsinline: payload.fetch(:playsinline, true)
        }
      end

      def item_type!(payload)
        return infer_type(payload) if payload[:type].nil?

        type = payload[:type].to_sym
        return type if ITEM_TYPES.include?(type)

        raise ArgumentError, "type must be :image or :video"
      end

      def infer_type(payload)
        return :video if payload[:src].to_s.end_with?(".mp4") || payload[:poster].present?

        :image
      end
    end
  end
end
