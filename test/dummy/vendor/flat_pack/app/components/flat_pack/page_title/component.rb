# frozen_string_literal: true

module FlatPack
  module PageTitle
    class Component < FlatPack::BaseComponent
      VARIANTS = %i[h1 h2 h3 h4 h5 h6].freeze

      renders_one :actions

      alias_method :actions_slot, :actions

      undef_method :with_actions, :with_actions_content

      def initialize(
        title:,
        subtitle: nil,
        variant: :h1,
        large_subtitle: false,
        title_color: nil,
        subtitle_color: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle
        @variant = variant.to_sym
        @large_subtitle = large_subtitle
        @title_color = title_color
        @subtitle_color = subtitle_color

        validate_title!
        validate_variant!
      end

      def call
        content_tag(:div, **container_attributes) { render_header_content }
      end

      def slot(*args, **kwargs, &block)
        return actions_slot if args.empty? && kwargs.empty? && !block_given?

        set_slot(:actions, nil, *args, **kwargs, &block)
      end

      def slot?
        actions?
      end

      def actions(*args, **kwargs, &block)
        warn_deprecated_api(:actions, :slot)
        slot(*args, **kwargs, &block)
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes("mb-6")
      end

      def render_header_content
        content_tag(:div, class: "flex items-start gap-4") do
          render_title_section
        end
      end

      def render_title_section
        content_tag(:div, class: "flex-1 min-w-0") do
          safe_join([
            render_title,
            render_subtitle,
            render_actions
          ].compact)
        end
      end

      def render_title
        content_tag(
          @variant,
          @title,
          class: title_classes,
          style: title_style
        )
      end

      def title_classes
        classes = ["font-bold", "leading-tight"]
        classes << "text-[var(--surface-content-color)]" unless @title_color
        classes.join(" ")
      end

      def title_style
        style_rules = ["font-size: #{heading_size_token}"]
        style_rules << "color: #{@title_color}" if @title_color
        style_rules.join("; ") + ";"
      end

      def heading_size_token
        "var(--page-title-#{@variant}-size)"
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: subtitle_classes, style: subtitle_style)
      end

      def subtitle_classes
        classes = []
        classes << "mt-2 text-lg" unless @large_subtitle
        classes << "text-[var(--surface-muted-content-color)]" unless @subtitle_color
        classes.join(" ").presence
      end

      def subtitle_style
        style_rules = []
        if @large_subtitle
          style_rules << "font-size: #{heading_size_token}"
          style_rules << "font-weight: bold"
          style_rules << "margin-top: 0"
        end
        style_rules << "color: #{@subtitle_color}" if @subtitle_color

        return nil if style_rules.empty?

        style_rules.join("; ") + ";"
      end

      def render_actions
        return nil unless slot?

        content_tag(:div, slot, class: "page-title-actions mt-4 flex flex-wrap items-center gap-3")
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_variant!
        return if VARIANTS.include?(@variant)

        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.join(", ")}"
      end
    end
  end
end
