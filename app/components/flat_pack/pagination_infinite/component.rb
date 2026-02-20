# frozen_string_literal: true

module FlatPack
  module PaginationInfinite
    class Component < FlatPack::BaseComponent
      def initialize(
        url:,
        page: 1,
        has_more: true,
        loading_text: "Loading more...",
        **system_arguments
      )
        super(**system_arguments)
        @url = url
        @page = page.to_i
        @has_more = has_more
        @loading_text = loading_text

        validate_url!
        validate_page!
      end

      def call
        return nil unless @has_more

        content_tag(:div, **container_attributes) do
          safe_join([
            render_trigger,
            render_loading_indicator
          ])
        end
      end

      private

      def render_trigger
        link_to(@url, **trigger_attributes) do
          "Load more"
        end
      end

      def render_loading_indicator
        content_tag(:div, **loading_attributes) do
          safe_join([
            render_spinner,
            content_tag(:span, @loading_text, class: "ml-2")
          ])
        end
      end

      def render_spinner
        content_tag(:svg,
          class: "animate-spin h-5 w-5",
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24") do
          safe_join([
            tag.circle(
              class: "opacity-25",
              cx: "12",
              cy: "12",
              r: "10",
              stroke: "currentColor",
              "stroke-width": "4"
            ),
            tag.path(
              class: "opacity-75",
              fill: "currentColor",
              d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
            )
          ])
        end
      end

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--pagination-infinite",
            "flat-pack--pagination-infinite-url-value": @url,
            "flat-pack--pagination-infinite-page-value": @page
          },
          class: "flex flex-col items-center gap-4 py-8"
        )
      end

      def trigger_attributes
        {
          href: @url,
          class: trigger_classes,
          data: {
            "flat-pack--pagination-infinite-target": "trigger",
            action: "click->flat-pack--pagination-infinite#loadMore"
          }
        }
      end

      def trigger_classes
        "inline-flex items-center justify-center px-6 py-3 text-sm font-medium rounded-[var(--radius-md)] bg-[var(--color-primary)] text-[var(--color-primary-text)] hover:opacity-90 transition-opacity focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)] focus-visible:ring-offset-2"
      end

      def loading_attributes
        {
          class: "flex items-center text-sm text-[var(--color-text-muted)]",
          data: {"flat-pack--pagination-infinite-target": "loading"},
          hidden: true
        }
      end

      def validate_url!
        return if @url.present?
        raise ArgumentError, "url is required"
      end

      def validate_page!
        return if @page > 0
        raise ArgumentError, "page must be greater than zero"
      end
    end
  end
end
