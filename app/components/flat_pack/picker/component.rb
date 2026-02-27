# frozen_string_literal: true

require "json"

module FlatPack
  module Picker
    class Component < FlatPack::BaseComponent
      SELECTION_MODES = %i[single multiple].freeze
      SEARCH_MODES = %i[local remote].freeze
      OUTPUT_MODES = %i[event field].freeze
      RESULTS_LAYOUTS = %i[list grid].freeze
      ACCEPTED_KINDS = %w[image file].freeze

      def initialize(
        id:,
        items: [],
        title: "Select Assets",
        subtitle: nil,
        confirm_text: "Use Selected",
        close_text: "Close",
        size: :lg,
        selection_mode: :multiple,
        accepted_kinds: ACCEPTED_KINDS,
        searchable: false,
        search_placeholder: "Search assets...",
        search_mode: :local,
        search_endpoint: nil,
        search_param: "q",
        output_mode: :event,
        output_target: nil,
        context: {},
        empty_state_text: "No assets found",
        results_layout: :list,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(20rem, 55vh, 30rem)",
        **system_arguments
      )
        super(**system_arguments)
        @id = id
        @title = title
        @subtitle = subtitle
        @confirm_text = confirm_text
        @close_text = close_text
        @size = size
        @selection_mode = selection_mode.to_sym
        @accepted_kinds = normalize_kinds(accepted_kinds)
        @searchable = searchable
        @search_placeholder = search_placeholder
        @search_mode = search_mode.to_sym
        @search_endpoint = search_endpoint.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_endpoint) : nil
        @search_param = search_param
        @output_mode = output_mode.to_sym
        @output_target = output_target
        @context = context.is_a?(Hash) ? context : {}
        @empty_state_text = empty_state_text
        @results_layout = results_layout.to_sym
        @modal_body_height_mode = modal_body_height_mode
        @modal_body_height = modal_body_height
        @items = normalize_items(items)

        validate_id!
        validate_selection_mode!
        validate_search_mode!
        validate_output_mode!
        validate_results_layout!
        validate_search_configuration!
        validate_search_endpoint!(search_endpoint) if search_endpoint.present?
      end

      def call
        render FlatPack::Modal::Component.new(
          id: @id,
          size: @size,
          body_height_mode: @modal_body_height_mode,
          body_height: @modal_body_height,
          **@system_arguments
        ) do |modal|
          modal.with_header do
            safe_join([
              content_tag(:h2, @title, class: "text-lg font-semibold text-(--surface-content-color)"),
              (@subtitle.present? ? content_tag(:p, @subtitle, class: "mt-1 text-sm text-(--surface-muted-content-color)") : nil)
            ].compact)
          end

          modal.with_body do
            content_tag(:div, **picker_attributes) do
              safe_join([
                render_search,
                tag.input(type: "hidden", data: {flat_pack__picker_target: "outputField"}),
                content_tag(:div, class: "min-h-0 flex-1 overflow-y-auto") do
                  safe_join([
                    content_tag(:div, "", class: "space-y-2", data: {flat_pack__picker_target: "results"}),
                    content_tag(:div, @empty_state_text, class: "hidden h-full min-h-32 items-center justify-center rounded-md border border-dashed border-(--surface-border-color) p-4 text-center text-sm text-(--surface-muted-content-color)", data: {flat_pack__picker_target: "emptyState"})
                  ])
                end,
                render_actions
              ].compact)
            end
          end
        end
      end

      private

      def render_search
        return unless @searchable

        render FlatPack::Search::Component.new(
          placeholder: @search_placeholder,
          name: "picker_query_#{@id}",
          max_width: :none,
          data: {
            flat_pack__picker_target: "searchInput",
            action: "input->flat-pack--picker#search"
          },
          aria: {
            label: "Search available assets"
          }
        )
      end

      def render_actions
        content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
          safe_join([
            render(
              FlatPack::Button::Component.new(
                text: @close_text,
                style: :secondary,
                data: {
                  action: "click->flat-pack--picker#clearSelection click->flat-pack--modal#close"
                }
              )
            ),
            render(
              FlatPack::Button::Component.new(
                text: @confirm_text,
                style: :primary,
                data: {
                  action: "click->flat-pack--picker#confirmSelection click->flat-pack--modal#close"
                }
              )
            )
          ])
        end
      end

      def picker_attributes
        {
          class: "flex h-full min-h-0 flex-col gap-4",
          data: {
            controller: "flat-pack--picker",
            flat_pack__picker_picker_id_value: @id,
            flat_pack__picker_items_value: @items.to_json,
            flat_pack__picker_selection_mode_value: @selection_mode,
            flat_pack__picker_accepted_kinds_value: @accepted_kinds.to_json,
            flat_pack__picker_searchable_value: @searchable,
            flat_pack__picker_search_mode_value: @search_mode,
            flat_pack__picker_search_endpoint_value: @search_endpoint,
            flat_pack__picker_search_param_value: @search_param,
            flat_pack__picker_output_mode_value: @output_mode,
            flat_pack__picker_output_target_value: @output_target,
            flat_pack__picker_context_value: @context.to_json,
            flat_pack__picker_empty_state_text_value: @empty_state_text,
            flat_pack__picker_results_layout_value: @results_layout
          }.compact
        }
      end

      def normalize_items(items)
        Array(items).filter_map.with_index do |item, index|
          source = item.respond_to?(:to_h) ? item.to_h : {}
          name = source[:name].presence || source["name"].presence
          next unless name

          {
            "id" => source[:id].presence || source["id"].presence || "picker-item-#{index}",
            "kind" => normalized_kind(source[:kind] || source["kind"]),
            "label" => source[:label].presence || source["label"].presence || name,
            "name" => name,
            "contentType" => source[:content_type].presence || source["content_type"].presence || source[:contentType].presence || source["contentType"].presence,
            "byteSize" => normalize_size(source[:byte_size] || source["byte_size"] || source[:byteSize] || source["byteSize"]),
            "thumbnailUrl" => source[:thumbnail_url].presence || source["thumbnail_url"].presence || source[:thumbnailUrl].presence || source["thumbnailUrl"].presence,
            "meta" => source[:meta].presence || source["meta"].presence,
            "payload" => normalize_payload(source[:payload] || source["payload"])
          }.compact
        end
      end

      def normalize_payload(payload)
        return {} unless payload.is_a?(Hash)

        payload.deep_stringify_keys
      end

      def normalize_kinds(kinds)
        normalized = Array(kinds).map { |kind| normalized_kind(kind) }.uniq
        normalized.presence || ACCEPTED_KINDS
      end

      def normalized_kind(kind)
        (kind.to_s == "image") ? "image" : "file"
      end

      def normalize_size(value)
        parsed = Integer(value, exception: false)
        parsed&.positive? ? parsed : nil
      end

      def validate_id!
        return if @id.present?

        raise ArgumentError, "id is required"
      end

      def validate_selection_mode!
        return if SELECTION_MODES.include?(@selection_mode)

        raise ArgumentError, "Invalid selection_mode: #{@selection_mode}. Must be one of: #{SELECTION_MODES.join(", ")}."
      end

      def validate_search_mode!
        return if SEARCH_MODES.include?(@search_mode)

        raise ArgumentError, "Invalid search_mode: #{@search_mode}. Must be one of: #{SEARCH_MODES.join(", ")}."
      end

      def validate_output_mode!
        return if OUTPUT_MODES.include?(@output_mode)

        raise ArgumentError, "Invalid output_mode: #{@output_mode}. Must be one of: #{OUTPUT_MODES.join(", ")}."
      end

      def validate_results_layout!
        return if RESULTS_LAYOUTS.include?(@results_layout)

        raise ArgumentError, "Invalid results_layout: #{@results_layout}. Must be one of: #{RESULTS_LAYOUTS.join(", ")}."
      end

      def validate_search_configuration!
        return unless @search_mode == :remote && @searchable
        return if @search_endpoint.present?

        raise ArgumentError, "search_endpoint is required when searchable is true and search_mode is :remote"
      end

      def validate_search_endpoint!(original_url)
        return if @search_endpoint.present?

        raise ArgumentError, "Unsafe search_endpoint detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
