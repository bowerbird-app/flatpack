# frozen_string_literal: true

module FlatPack
  module PaginationInfinite
    class Component < FlatPack::BaseComponent
      LOADING_VARIANTS = {
        table: :table,
        cards: :cards
      }.freeze

      def initialize(
        url:,
        page: 1,
        has_more: true,
        loading_text: "Loading more...",
        loading_variant: :table,
        **system_arguments
      )
        super(**system_arguments)
        @url = url
        @page = page.to_i
        @has_more = has_more
        @loading_text = loading_text
        @loading_variant = loading_variant.to_sym

        validate_url!
        validate_page!
        validate_loading_variant!
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
        content_tag(:div, nil, **trigger_attributes)
      end

      def render_loading_indicator
        content_tag(:div, **loading_attributes) do
          @loading_variant == :cards ? render_cards_loading_indicator : render_table_loading_indicator
        end
      end

      def render_table_loading_indicator
        content_tag(:div, class: "overflow-x-auto border border-border rounded-lg") do
          content_tag(:table, class: "w-full") do
            content_tag(:tbody) do
              safe_join(Array.new(5) do
                content_tag(:tr, class: "border-t border-border") do
                  safe_join([
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "70px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "140px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "170px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "80px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "100px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "90px")), class: "px-4 py-3"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "120px")), class: "px-4 py-3")
                  ])
                end
              end)
            end
          end
        end
      end

      def render_cards_loading_indicator
        content_tag(:div, class: "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4") do
          safe_join(Array.new(8) do
            content_tag(:div, class: "border border-border rounded-lg p-4 space-y-3") do
              safe_join([
                render(FlatPack::Skeleton::Component.new(variant: :rectangle, height: "120px")),
                render(FlatPack::Skeleton::Component.new(variant: :title, width: "60%")),
                render(FlatPack::Skeleton::Component.new(variant: :text, width: "90%")),
                render(FlatPack::Skeleton::Component.new(variant: :text, width: "75%"))
              ])
            end
          end)
        end
      end

      def container_attributes
        merge_attributes(
          data: {
            controller: "flat-pack--pagination-infinite",
            "flat-pack--pagination-infinite-url-value": @url,
            "flat-pack--pagination-infinite-page-value": @page,
            "flat-pack--pagination-infinite-loading-variant-value": @loading_variant
          },
          class: "flex flex-col items-center gap-4 py-8"
        )
      end

      def trigger_attributes
        {
          class: trigger_classes,
          data: {
            "flat-pack--pagination-infinite-target": "trigger"
          },
          "aria-hidden": "true"
        }
      end

      def trigger_classes
        "h-px w-full opacity-0 pointer-events-none"
      end

      def loading_attributes
        {
          class: "w-full self-stretch",
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

      def validate_loading_variant!
        return if LOADING_VARIANTS.key?(@loading_variant)
        raise ArgumentError, "Invalid loading_variant: #{@loading_variant}. Must be one of: #{LOADING_VARIANTS.keys.join(", ")}"
      end
    end
  end
end
