# frozen_string_literal: true

module FlatPack
  module Reveal
    class Component < FlatPack::BaseComponent
      REVEALS = FlatPack::Motion::REVEALS
      TAGS = FlatPack::Motion::TAGS

      def initialize(reveal:, stagger: false, parallax: false, intensity: nil, tag: :div, text: nil, **system_arguments)
        super(**system_arguments)
        @reveal = reveal.to_sym
        @stagger = stagger
        @parallax = parallax
        @intensity = intensity
        @tag = tag
        @text = text
        validate_text_option!(@text, name: :text) unless @text.nil?
        @motion_attributes = FlatPack::Motion.attributes(
          reveal: @reveal,
          stagger: @stagger,
          parallax: @parallax,
          intensity: @intensity,
          text: text_reveal?
        )
      end

      def call
        if text_reveal?
          raise ArgumentError, "text is required" if chunks.empty?
        elsif content.blank?
          raise ArgumentError, "content is required"
        end

        content_tag(root_tag, text_reveal? ? text_markup : content, **root_attributes)
      end

      private

      def text_reveal?
        FlatPack::Motion::TEXT_REVEALS.include?(@reveal)
      end

      def root_tag
        name = @tag.to_sym
        return name if TAGS.include?(name)

        raise ArgumentError, "Invalid tag: #{@tag}. Must be one of: #{TAGS.join(", ")}"
      end

      def root_attributes
        merge_attributes
      end

      def plain_text
        source = @text.nil? ? strip_tags(content.to_s) : @text.to_s
        source.to_s.gsub(/\r\n?/, "\n")
      end

      def chunks
        if @reveal == :lines
          plain_text.split("\n").map { |line| line.strip.gsub(/\s+/, " ") }.reject(&:blank?)
        else
          plain_text.gsub(/\s+/, " ").strip.split(" ").reject(&:blank?)
        end
      end

      def text_markup
        masks = chunks.each_with_index.map { |chunk, index| mask_tag(chunk, index) }
        safe_join([
          content_tag(:span, plain_label, class: "fp-reveal__plain"),
          safe_join(masks, (@reveal == :words) ? " " : "")
        ])
      end

      def plain_label
        chunks.join(" ")
      end

      def mask_tag(chunk, index)
        content_tag(
          :span,
          content_tag(:span, chunk, class: "fp-reveal__chunk"),
          class: "fp-reveal__mask",
          aria: {hidden: true},
          style: "--reveal-index: #{index}"
        )
      end
    end
  end
end
