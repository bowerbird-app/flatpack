# frozen_string_literal: true

module FlatPack
  module Embed
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "fp-embed" "fp-embed__frame" "fp-embed__caption" "relative" "w-full" "max-w-full"
      # "overflow-hidden" "rounded-[var(--media-radius)]" "aspect-[16/9]" "aspect-[4/3]"
      # "aspect-square" "mt-2" "text-sm" "text-[var(--surface-muted-content-color)]"

      LOADINGS = %w[lazy eager].freeze
      REFERRER_POLICIES = %w[
        no-referrer
        no-referrer-when-downgrade
        origin
        origin-when-cross-origin
        same-origin
        strict-origin
        strict-origin-when-cross-origin
        unsafe-url
      ].freeze

      def initialize(
        src:,
        title:,
        aspect_ratio: "16/9",
        allow: nil,
        sandbox: nil,
        loading: "lazy",
        referrerpolicy: "strict-origin-when-cross-origin",
        caption: nil,
        allowfullscreen: false,
        **system_arguments
      )
        super(**system_arguments)
        @src = FlatPack::AttributeSanitizer.sanitize_url(src)
        @title = title
        @aspect_ratio = normalize_aspect_ratio(aspect_ratio)
        @allow = allow
        @sandbox = sandbox
        @loading = loading.to_s
        @referrerpolicy = referrerpolicy.to_s
        @caption = caption
        @allowfullscreen = allowfullscreen

        validate_src!(src)
        validate_title!
        validate_allow!
        validate_sandbox!
        validate_loading!
        validate_referrerpolicy!
        validate_caption!
        validate_allowfullscreen!
      end

      private

      def caption_text
        @caption.presence || content.presence
      end

      def root_attributes
        merge_attributes(class: "fp-embed")
      end

      def frame_attributes
        {class: frame_classes}
      end

      def frame_classes
        [
          "fp-embed__frame",
          "relative",
          "w-full",
          "max-w-full",
          "overflow-hidden",
          "rounded-[var(--media-radius)]",
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

      def iframe_attributes
        attributes = {
          src: @src,
          title: @title,
          loading: @loading,
          referrerpolicy: @referrerpolicy
        }
        attributes[:allow] = @allow unless @allow.nil?
        attributes[:sandbox] = @sandbox unless @sandbox.nil?
        attributes[:allowfullscreen] = true if @allowfullscreen
        attributes
      end

      def caption_classes
        "fp-embed__caption mt-2 text-sm text-[var(--surface-muted-content-color)]"
      end

      def normalize_aspect_ratio(value)
        ratio = value.to_s.strip.delete(" ")

        unless ratio.match?(/\A\d+(?:\.\d+)?\/\d+(?:\.\d+)?\z/)
          raise ArgumentError, "aspect_ratio must look like \"16/9\""
        end

        ratio
      end

      def validate_src!(original)
        return if @src.present?

        raise ArgumentError, "Invalid src: #{original.inspect}. Must be an http(s) or relative URL."
      end

      def validate_title!
        unless @title.is_a?(String)
          raise ArgumentError, "title must be a String"
        end

        return if @title.strip.present?

        raise ArgumentError, "title is required"
      end

      def validate_allow!
        return if @allow.nil?
        return if @allow.is_a?(String)

        raise ArgumentError, "allow must be a String"
      end

      def validate_sandbox!
        return if @sandbox.nil?
        return if @sandbox.is_a?(String)

        raise ArgumentError, "sandbox must be a String"
      end

      def validate_loading!
        return if LOADINGS.include?(@loading)

        raise ArgumentError, "loading must be one of: #{LOADINGS.join(", ")}"
      end

      def validate_referrerpolicy!
        return if REFERRER_POLICIES.include?(@referrerpolicy)

        raise ArgumentError, "referrerpolicy must be one of: #{REFERRER_POLICIES.join(", ")}"
      end

      def validate_caption!
        return if @caption.nil?

        validate_text_option!(@caption, name: :caption)
      end

      def validate_allowfullscreen!
        return if [true, false].include?(@allowfullscreen)

        raise ArgumentError, "allowfullscreen must be true or false"
      end
    end
  end
end
