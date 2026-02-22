# frozen_string_literal: true

module FlatPack
  module SectionTitle
    class Component < FlatPack::BaseComponent
      def initialize(
        title:,
        subtitle: nil,
        anchor_link: false,
        anchor_id: nil,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @subtitle = subtitle
        @anchor_link = anchor_link
        @explicit_anchor_id = anchor_id

        validate_title!
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
          "my-8",
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
        content_tag(:h2, @title, class: "text-2xl font-semibold text-foreground leading-tight")
      end

      def render_anchor_link
        return nil unless @anchor_link

        render FlatPack::Tooltip::Component.new(text: "Copy link", placement: :top) do
          content_tag(:a,
            href: "##{anchor_id}",
            class: "shrink-0 transition-opacity text-muted-foreground hover:text-foreground",
            style: "opacity: 0",
            data: {
              flat_pack__section_title_anchor_target: "link",
              action: "click->flat-pack--section-title-anchor#copy"
            },
            aria: {
              label: "Copy link to #{@title}"
            }) do
            render FlatPack::Shared::IconComponent.new(name: :link, size: :sm)
          end
        end
      end

      def render_subtitle
        return nil unless @subtitle

        content_tag(:p, @subtitle, class: "mt-1 text-base text-muted-foreground")
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

      def validate_title!
        return if @title.present?
        raise ArgumentError, "title is required"
      end
    end
  end
end
