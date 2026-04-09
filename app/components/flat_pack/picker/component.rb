# frozen_string_literal: true

require "json"

module FlatPack
  module Picker
    class Component < FlatPack::BaseComponent
      SELECTION_MODES = %i[single multiple].freeze
      SEARCH_MODES = %i[local remote].freeze
      OUTPUT_MODES = %i[event field].freeze
      RESULTS_LAYOUTS = %i[list grid].freeze
      FORM_VALUE_MODES = %i[id ids json].freeze
      ACCEPTED_KINDS = %w[image file record].freeze

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
        items_height: "max-content",
        modal: false,
        auto_confirm: false,
        modal_body_height_mode: :fixed,
        modal_body_height: "clamp(20rem, 55vh, 30rem)",
        form: nil,
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
        @items_height = normalize_items_height(items_height)
        @modal = !!modal
        @auto_confirm = !!auto_confirm
        @modal_body_height_mode = modal_body_height_mode
        @modal_body_height = modal_body_height
        @form = normalize_form(form)
        @items = normalize_items(items)

        validate_id!
        validate_selection_mode!
        validate_search_mode!
        validate_output_mode!
        validate_results_layout!
        validate_search_configuration!
        validate_search_endpoint!(search_endpoint) if search_endpoint.present?
        validate_form!
      end

      def call
        return render_inline_picker unless @modal

        render FlatPack::Modal::Component.new(
          id: @id,
          size: @size,
          body_height_mode: @modal_body_height_mode,
          body_height: @modal_body_height,
          **@system_arguments
        ) do |modal|
          modal.header { render_header_content }

          modal.body { render_picker_shell }
        end
      end

      private

      def render_inline_picker
        content_tag(:div, **inline_attributes) do
          safe_join([
            render_inline_header,
            content_tag(:div, render_picker_shell, **inline_body_attributes)
          ].compact)
        end
      end

      def render_picker_shell
        return render_picker_content unless @form.present?

        form_with(**picker_form_attributes) do
          render_picker_content
        end
      end

      def render_header_content
        safe_join([
          content_tag(:h2, @title, class: "text-lg font-semibold text-(--surface-content-color)"),
          (@subtitle.present? ? content_tag(:p, @subtitle, class: "mt-1 text-sm text-(--surface-muted-content-color)") : nil)
        ].compact)
      end

      def render_inline_header
        return unless @title.present? || @subtitle.present?

        content_tag(:div, render_header_content, class: "shrink-0")
      end

      def render_picker_content
        content_tag(:div, **picker_attributes) do
          safe_join([
            render_search,
            (@form.present? ? content_tag(:div, "", class: "hidden", data: {flat_pack__picker_target: "formFields"}) : nil),
            tag.input(type: "hidden", data: {flat_pack__picker_target: "outputField"}),
            content_tag(:div, **items_region_attributes) do
              safe_join([
                content_tag(:div, "", class: "space-y-2", data: {flat_pack__picker_target: "results"}),
                content_tag(:div, @empty_state_text, class: "hidden h-full min-h-32 items-center justify-center rounded-md border border-dashed border-(--surface-border-color) p-4 text-center text-sm text-(--surface-muted-content-color)", data: {flat_pack__picker_target: "emptyState"})
              ])
            end,
            render_actions
          ].compact)
        end
      end

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
        return if auto_confirm_single_select?

        close_actions = ["click->flat-pack--picker#clearSelection"]
        close_actions << "click->flat-pack--modal#close" if @modal

        confirm_actions = ["click->flat-pack--picker#confirmSelection"]
        confirm_actions << "click->flat-pack--modal#close" if @modal && @form.blank?

        content_tag(:div, class: "mt-4 flex items-center justify-end gap-2") do
          safe_join([
            render(
              FlatPack::Button::Component.new(
                text: @close_text,
                style: :secondary,
                type: "button",
                data: {
                  action: close_actions.join(" ")
                }
              )
            ),
            render(
              FlatPack::Button::Component.new(
                text: @confirm_text,
                style: :primary,
                type: @form.present? ? "submit" : "button",
                data: {
                  action: confirm_actions.join(" ")
                }
              )
            )
          ])
        end
      end

      def auto_confirm_single_select?
        @selection_mode == :single && @auto_confirm
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
            flat_pack__picker_results_layout_value: @results_layout,
            flat_pack__picker_modal_value: @modal,
            flat_pack__picker_auto_confirm_value: @auto_confirm,
            flat_pack__picker_form_value: picker_form_value
          }.compact
        }
      end

      def items_region_attributes
        attributes = {
          class: items_region_classes,
          data: {
            flat_pack_picker_items_region: true
          }
        }

        style = items_region_style
        attributes[:style] = style if style.present?
        attributes
      end

      def items_region_classes
        [
          "min-h-0",
          (@items_height == "max-content") ? "flex-1" : "shrink-0",
          "overflow-y-auto"
        ].join(" ")
      end

      def items_region_style
        return nil if @items_height == "max-content"

        "--flatpack-picker-items-height: #{@items_height}; height: var(--flatpack-picker-items-height); max-height: 100%;"
      end

      def picker_form_attributes
        {
          url: @form.fetch(:url),
          method: @form.fetch(:method),
          scope: @form[:scope],
          data: {
            turbo: @form.fetch(:turbo)
          },
          html: {
            class: "h-full"
          }
        }.compact
      end

      def picker_form_value
        return unless @form.present?

        {
          field: @form.fetch(:field),
          scope: @form[:scope],
          valueMode: @form.fetch(:value_mode),
          valuePath: @form.fetch(:value_path)
        }.to_json
      end

      def inline_attributes
        merge_attributes(
          id: @id,
          class: inline_wrapper_classes
        )
      end

      def inline_wrapper_classes
        classes(
          "relative",
          "flex",
          "flex-col",
          "min-h-0",
          "w-full",
          "overflow-hidden",
          FlatPack::Modal::Component::SIZES.fetch(@size),
          "p-4",
          "sm:p-6",
          "bg-[var(--modal-surface-color)]",
          "rounded-lg",
          "shadow-lg",
          "border",
          "border-[var(--modal-border-color)]"
        )
      end

      def inline_body_attributes
        attributes = {
          class: inline_body_classes
        }

        height_style = inline_body_style
        attributes[:style] = height_style if height_style.present?
        attributes
      end

      def inline_body_classes
        classes(
          "min-h-0",
          (@modal_body_height_mode == :auto) ? "flex-1" : "shrink-0",
          "overflow-y-auto",
          "py-4",
          "text-sm",
          "text-[var(--modal-body-color)]"
        )
      end

      def inline_body_style
        return nil unless @modal_body_height_mode != :auto

        case @modal_body_height_mode.to_sym
        when :fixed
          "--flatpack-modal-body-height: #{@modal_body_height}; height: fit-content; max-height: var(--flatpack-modal-body-height);"
        when :min
          "--flatpack-modal-body-height: #{@modal_body_height}; min-height: var(--flatpack-modal-body-height);"
        end
      end

      def normalize_items(items)
        Array(items).filter_map.with_index do |item, index|
          source = item.respond_to?(:to_h) ? item.to_h : {}
          name = source[:name].presence || source["name"].presence
          next unless name

          kind = normalized_kind(source[:kind] || source["kind"])
          label = source[:label].presence || source["label"].presence || name
          thumbnail_url = source[:thumbnail_url].presence || source["thumbnail_url"].presence

          {
            "id" => source[:id].presence || source["id"].presence || "picker-item-#{index}",
            "kind" => kind,
            "label" => label,
            "title" => normalize_display_title(source, label, name),
            "name" => name,
            "contentType" => source[:content_type].presence || source["content_type"].presence || source[:contentType].presence || source["contentType"].presence,
            "byteSize" => normalize_size(source[:byte_size] || source["byte_size"] || source[:byteSize] || source["byteSize"]),
            "thumbnail_url" => thumbnail_url,
            "icon" => normalize_display_icon(source, kind, thumbnail_url),
            "description" => normalize_display_description(source, kind),
            "right_text" => normalize_display_right_text(source),
            "path" => source[:path].presence || source["path"].presence,
            "badge" => source[:badge].presence || source["badge"].presence,
            "meta" => source[:meta].presence || source["meta"].presence,
            "payload" => normalize_payload(source[:payload] || source["payload"])
          }.compact
        end
      end

      def normalize_display_title(source, label, name)
        source[:title].presence || source["title"].presence || label || name
      end

      def normalize_display_icon(source, kind, thumbnail_url)
        return source[:icon].presence || source["icon"].presence if source[:icon].presence || source["icon"].presence
        return nil if thumbnail_url.present?

        default_icon_for_kind(kind)
      end

      def normalize_display_description(source, kind)
        explicit_description = source[:description].presence || source["description"].presence
        path = source[:path].presence || source["path"].presence

        return join_display_parts(explicit_description, path) if explicit_description.present? || path.present?
        return nil if kind == "record"

        join_display_parts(
          source[:content_type].presence || source["content_type"].presence || source[:contentType].presence || source["contentType"].presence,
          human_size(source[:byte_size] || source["byte_size"] || source[:byteSize] || source["byteSize"])
        )
      end

      def normalize_display_right_text(source)
        source[:right_text].presence || source["right_text"].presence ||
          source[:meta].presence || source["meta"].presence ||
          source[:badge].presence || source["badge"].presence
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
        normalized = kind.to_s
        ACCEPTED_KINDS.include?(normalized) ? normalized : "file"
      end

      def normalize_size(value)
        parsed = Integer(value, exception: false)
        parsed&.positive? ? parsed : nil
      end

      def normalize_items_height(value)
        case value
        when nil
          "max-content"
        when Integer
          "#{value}px"
        when Symbol
          value.to_s.tr("_", "-")
        else
          value.to_s.strip.presence || "max-content"
        end
      end

      def human_size(value)
        bytes = normalize_size(value)
        return nil unless bytes

        return "#{bytes} B" if bytes < 1024

        units = %w[KB MB GB].freeze
        unit_index = 0
        size = bytes.to_f / 1024

        while size >= 1024 && unit_index < units.length - 1
          size /= 1024
          unit_index += 1
        end

        formatted_size = (size >= 10) ? size.round.to_s : Kernel.format("%.1f", size)
        "#{formatted_size} #{units[unit_index]}"
      end

      def join_display_parts(*parts)
        parts.filter_map(&:presence).join(" • ").presence
      end

      def default_icon_for_kind(kind)
        case kind
        when "image"
          "photo"
        when "record"
          "folder"
        else
          "document-text"
        end
      end

      def normalize_form(form)
        return nil if form.blank?

        source = form.respond_to?(:to_h) ? form.to_h.symbolize_keys : {}
        sanitized_url = source[:url].present? ? FlatPack::AttributeSanitizer.sanitize_url(source[:url]) : nil

        {
          url: sanitized_url,
          method: normalize_form_method(source[:method]),
          scope: source[:scope].presence&.to_s,
          field: source[:field].presence&.to_s,
          value_mode: normalize_form_value_mode(source[:value_mode]),
          value_path: source[:value_path].presence&.to_s || "id",
          turbo: source.key?(:turbo) ? !!source[:turbo] : true
        }
      end

      def normalize_form_method(method)
        return :post if method.blank?

        method.to_sym
      end

      def normalize_form_value_mode(value_mode)
        return ((@selection_mode == :multiple) ? :ids : :id) if value_mode.blank?

        value_mode.to_sym
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

      def validate_form!
        return unless @form.present?

        raise ArgumentError, "form[:url] is required when form mode is enabled" unless @form[:url].present?
        raise ArgumentError, "form[:field] is required when form mode is enabled" unless @form[:field].present?

        unless FORM_VALUE_MODES.include?(@form[:value_mode])
          raise ArgumentError, "Invalid form value_mode: #{@form[:value_mode]}. Must be one of: #{FORM_VALUE_MODES.join(", ")}."
        end

        if @selection_mode == :multiple && @form[:value_mode] == :id
          raise ArgumentError, "form[:value_mode] cannot be :id when selection_mode is :multiple"
        end

        if @selection_mode == :single && @form[:value_mode] == :ids
          raise ArgumentError, "form[:value_mode] cannot be :ids when selection_mode is :single"
        end
      end
    end
  end
end
