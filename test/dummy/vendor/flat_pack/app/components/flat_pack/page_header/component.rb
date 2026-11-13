# frozen_string_literal: true

module FlatPack
  module PageHeader
    class Component < FlatPack::BaseComponent
      def initialize(
        title:,
        subtitle: nil,
        large_subtitle: false,
        title_color: nil,
        subtitle_color: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle
        @large_subtitle = large_subtitle
        @title_color = title_color
        @subtitle_color = subtitle_color

        validate_title!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            content_tag(:h1, @title, class: title_classes, style: title_style),
            (@subtitle.present? ? content_tag(:p, @subtitle, class: subtitle_classes, style: subtitle_style) : nil)
          ].compact)
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: classes(
            "pb-8 mb-6"
          )
        )
      end

      def title_classes
        classes = ["fp-type-heading", "fp-text-balance"]
        classes << "text-[var(--surface-content-color)]" unless @title_color
        classes.join(" ")
      end

      def title_style
        rules = ["font-size: var(--text-4xl)"]
        rules << "color: #{@title_color}" if @title_color
        "#{rules.join("; ")};"
      end

      def subtitle_classes
        classes = []
        classes << "mt-2 fp-type-body fp-type-body--lg fp-text-pretty" unless @large_subtitle
        classes << "text-[var(--surface-muted-content-color)]" unless @subtitle_color
        classes.join(" ").presence
      end

      def subtitle_style
        style_rules = []
        if @large_subtitle
          style_rules << "font-size: var(--page-title-h1-size)"
          style_rules << "font-weight: var(--type-heading-weight)"
          style_rules << "margin-top: 0"
        end
        style_rules << "color: #{@subtitle_color}" if @subtitle_color

        return nil if style_rules.empty?

        style_rules.join("; ") + ";"
      end

      def validate_title!
        return if @title.present?

        raise ArgumentError, "title is required"
      end
    end
  end
end
