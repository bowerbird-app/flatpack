# frozen_string_literal: true

module FlatPack
  module PaginationInfinite
    class Component < FlatPack::BaseComponent
      LOADING_VARIANTS = {
        table: :table,
        cards: :cards,
        inline: :inline
      }.freeze

      INSERT_MODES = {
        append: :append,
        prepend: :prepend
      }.freeze

      def initialize(
        url:,
        page: 1,
        has_more: true,
        loading_text: "Loading more...",
        loading_variant: :table,
        insert_mode: :append,
        observe_root_selector: nil,
        cursor_selector: nil,
        cursor_param: nil,
        batch_size: nil,
        batch_size_param: "limit",
        preserve_scroll_position: false,
        **system_arguments
      )
        super(**system_arguments)
        @url = url
        @page = page.to_i
        @has_more = has_more
        @loading_text = loading_text
        @loading_variant = loading_variant.to_sym
        @insert_mode = insert_mode.to_sym
        @observe_root_selector = observe_root_selector.to_s.presence
        @cursor_selector = cursor_selector.to_s.presence
        @cursor_param = cursor_param.to_s.presence
        @batch_size = batch_size&.to_i
        @batch_size_param = batch_size_param.to_s.presence
        @preserve_scroll_position = preserve_scroll_position

        validate_url!
        validate_page!
        validate_loading_variant!
        validate_insert_mode!
        validate_batch_size!
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
          case @loading_variant
          when :cards
            render_cards_loading_indicator
          when :inline
            render_inline_loading_indicator
          else
            render_table_loading_indicator
          end
        end
      end

      def render_table_loading_indicator
        content_tag(:div, class: "overflow-x-auto border border-[var(--surface-border-color)] rounded-lg") do
          content_tag(:table, class: "w-full") do
            content_tag(:tbody) do
              safe_join(Array.new(5) do
                content_tag(:tr, class: "border-t border-[var(--surface-border-color)]") do
                  safe_join([
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "70px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "140px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "170px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "80px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "100px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "90px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]"),
                    content_tag(:td, render(FlatPack::Skeleton::Component.new(variant: :text, width: "120px")), class: "px-[var(--table-padding)] py-[var(--table-padding)]")
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
            content_tag(:div, class: "border border-[var(--surface-border-color)] rounded-lg p-[var(--card-padding-md)] space-y-3") do
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

      def render_inline_loading_indicator
        content_tag(:div, class: "py-2 text-sm text-[var(--surface-muted-content-color)]") do
          @loading_text
        end
      end

      def container_attributes
        merge_attributes(
          data: data_attributes,
          class: container_classes
        )
      end

      def data_attributes
        {
          controller: "flat-pack--pagination-infinite",
          "flat-pack--pagination-infinite-url-value": @url,
          "flat-pack--pagination-infinite-page-value": @page,
          "flat-pack--pagination-infinite-loading-variant-value": @loading_variant,
          "flat-pack--pagination-infinite-insert-mode-value": @insert_mode,
          "flat-pack--pagination-infinite-observe-root-selector-value": @observe_root_selector,
          "flat-pack--pagination-infinite-cursor-selector-value": @cursor_selector,
          "flat-pack--pagination-infinite-cursor-param-value": @cursor_param,
          "flat-pack--pagination-infinite-batch-size-value": @batch_size,
          "flat-pack--pagination-infinite-batch-size-param-value": @batch_size_param,
          "flat-pack--pagination-infinite-preserve-scroll-position-value": @preserve_scroll_position
        }.compact
      end

      def container_classes
        classes(
          "flex flex-col items-center gap-4",
          (@insert_mode == :prepend) ? "py-2" : "py-8"
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

      def validate_insert_mode!
        return if INSERT_MODES.key?(@insert_mode)
        raise ArgumentError, "Invalid insert_mode: #{@insert_mode}. Must be one of: #{INSERT_MODES.keys.join(", ")}"
      end

      def validate_batch_size!
        return if @batch_size.nil?
        return if @batch_size > 0

        raise ArgumentError, "batch_size must be greater than zero"
      end
    end
  end
end
