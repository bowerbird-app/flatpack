# frozen_string_literal: true

module FlatPack
  module SectionTitle
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-2xl" "text-lg" "text-base" "text-sm" "text-xs" "font-semibold" "leading-tight"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
      # "mt-1" "w-3" "h-3"
      SIZES = {
        lg: {
          heading: "text-2xl font-semibold text-[var(--surface-content-color)] leading-tight",
          subtitle: "mt-1 text-base text-[var(--surface-muted-content-color)]",
          icon: :sm
        },
        md: {
          heading: "text-lg font-semibold text-[var(--surface-content-color)] leading-tight",
          subtitle: "mt-1 text-sm text-[var(--surface-muted-content-color)]",
          icon: :sm
        },
        sm: {
          heading: "text-base font-semibold text-[var(--surface-content-color)] leading-tight",
          subtitle: "mt-1 text-xs text-[var(--surface-muted-content-color)]",
          icon: :sm,
          icon_class: "w-3 h-3"
        }
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "my-8" "my-6" "my-4"
      SPACINGS = {
        lg: "my-8",
        md: "my-6",
        sm: "my-4",
        none: nil
      }.freeze

      LEVELS = %i[h1 h2 h3 h4 h5 h6].freeze

      def initialize(
        title:,
        subtitle: nil,
        anchor_link: false,
        anchor_id: nil,
        size: :lg,
        spacing: :lg,
        level: :h2,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle
        @anchor_link = anchor_link
        @explicit_anchor_id = anchor_id
        @size = size.to_sym
        @spacing = spacing.to_sym
        @level = level.to_sym

        validate_title!
        validate_size!
        validate_spacing!
        validate_level!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_title_row,
            render_subtitle
          ].compact)
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes,
          id: container_id,
          data: container_data
        )
      end

      def container_classes
        classes(
          "fp-section-title",
          "min-w-0",
          spacing_class,
          (@anchor_link ? "fp-section-title-anchor scroll-mt-24" : nil)
        )
      end

      def container_id
        return nil unless @anchor_link
        anchor_id
      end

      def render_title_row
        content_tag(:div, class: "flex items-center gap-2") do
          safe_join([
            render_title,
            render_anchor_link
          ].compact)
        end
      end

      def render_title
        content_tag(@level, @title, class: size_config.fetch(:heading))
      end

      def render_anchor_link
        return nil unless @anchor_link

        render FlatPack::Tooltip::Component.new(text: fp_t("section_title.copy_link"), placement: :top) do
          content_tag(:a,
            href: "##{anchor_id}",
            class: "shrink-0 transition-opacity text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)]",
            style: "opacity: 0",
            data: {
              flat_pack__section_title_anchor_target: "link",
              action: "click->flat-pack--section-title-anchor#copy"
            },
            aria: {
              label: fp_t("section_title.copy_link_to", title: @title)
            }) do
            render FlatPack::Shared::IconComponent.new(**icon_arguments)
          end
        end
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: size_config.fetch(:subtitle))
      end

      def anchor_id
        @anchor_id ||= begin
          custom_id = @explicit_anchor_id.presence || html_attributes[:id].presence
          custom_id.presence || @title.to_s.parameterize.presence || "section-title"
        end
      end

      def container_data
        return {} unless @anchor_link

        {
          controller: "flat-pack--section-title-anchor",
          action: "mouseenter->flat-pack--section-title-anchor#show mouseleave->flat-pack--section-title-anchor#hide focusin->flat-pack--section-title-anchor#show focusout->flat-pack--section-title-anchor#hide"
        }
      end

      def size_config
        SIZES.fetch(@size)
      end

      def spacing_class
        SPACINGS.fetch(@spacing)
      end

      def icon_arguments
        arguments = {name: :link, size: size_config.fetch(:icon)}
        icon_class = size_config[:icon_class]
        arguments[:class] = icon_class if icon_class
        arguments
      end

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_spacing!
        return if SPACINGS.key?(@spacing)
        raise ArgumentError, "Invalid spacing: #{@spacing}. Must be one of: #{SPACINGS.keys.join(", ")}"
      end

      def validate_level!
        return if LEVELS.include?(@level)
        raise ArgumentError, "Invalid level: #{@level}. Must be one of: #{LEVELS.join(", ")}"
      end
    end
  end
end
