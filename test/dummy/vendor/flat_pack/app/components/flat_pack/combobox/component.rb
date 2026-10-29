# frozen_string_literal: true

module FlatPack
  module Combobox
    class Component < FlatPack::BaseComponent
      SEARCH_MODES = %i[local remote].freeze
      DEFAULT_SEARCH_MODE = :local
      DEFAULT_DEBOUNCE = 300
      DEFAULT_MIN_SEARCH_LENGTH = 2
      DEFAULT_SEARCH_PARAM = "q"

      def initialize(
        name:,
        options: nil,
        value: nil,
        label: nil,
        placeholder: FlatPack::Copy::OMITTED,
        disabled: false,
        required: false,
        empty_text: FlatPack::Copy::OMITTED,
        loading_text: FlatPack::Copy::OMITTED,
        hint_text: FlatPack::Copy::OMITTED,
        search_mode: DEFAULT_SEARCH_MODE,
        search_endpoint: nil,
        search_param: DEFAULT_SEARCH_PARAM,
        min_search_length: DEFAULT_MIN_SEARCH_LENGTH,
        debounce: DEFAULT_DEBOUNCE,
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @options = normalize_options(options)
        @value = value.to_s.presence
        @label = label
        @placeholder = fp_text(placeholder, "combobox.placeholder")
        @disabled = disabled
        @required = required
        @empty_text = fp_text(empty_text, "combobox.empty")
        @loading_text = fp_text(loading_text, "combobox.searching")
        @search_mode = search_mode.to_sym
        @search_endpoint = search_endpoint.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_endpoint) : nil
        @search_param = search_param.presence || DEFAULT_SEARCH_PARAM
        @min_search_length = [min_search_length.to_i, 1].max
        @debounce = [debounce.to_i, 0].max
        @hint_text = fp_text(hint_text, "combobox.type_to_search", count: @min_search_length)
        @list_id = "fp-combobox-#{SecureRandom.hex(4)}"
        validate_name!
        validate_search_mode!
        validate_search_endpoint!(search_endpoint) if search_endpoint.present?
        validate_search_configuration!
        validate_options!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_label,
            render_control,
            render_hidden_field,
            render_list
          ].compact)
        end
      end

      private

      def normalize_options(options)
        Array(options).map do |option|
          if option.is_a?(Hash)
            {
              value: option[:value].to_s,
              label: (option[:label] || option[:value]).to_s,
              subtitle: option[:subtitle].to_s.presence
            }
          else
            {value: option.to_s, label: option.to_s, subtitle: nil}
          end
        end
      end

      def selected_label
        match = @options.find { |option| option[:value] == @value }
        match ? match[:label] : @value
      end

      def remote?
        @search_mode == :remote
      end

      def root_attributes
        merge_attributes(
          class: "relative w-full",
          data: root_data
        )
      end

      def root_data
        data = {
          controller: "flat-pack--combobox",
          "flat-pack--combobox-empty-text-value": @empty_text,
          "flat-pack--combobox-loading-text-value": @loading_text,
          "flat-pack--combobox-hint-text-value": @hint_text,
          "flat-pack--combobox-search-mode-value": @search_mode,
          "flat-pack--combobox-search-param-value": @search_param,
          "flat-pack--combobox-min-search-length-value": @min_search_length,
          "flat-pack--combobox-debounce-value": @debounce
        }
        data["flat-pack--combobox-search-endpoint-value"] = @search_endpoint if @search_endpoint.present?
        data
      end

      def render_label
        return unless @label.present?

        content_tag(:label, @label, for: input_id, class: "mb-1 block text-sm font-medium text-[var(--surface-content-color)]")
      end

      def render_control
        content_tag(:div, class: control_classes) do
          safe_join([
            content_tag(:input, nil, **input_attributes),
            content_tag(:span, class: "pointer-events-none text-[var(--surface-muted-content-color)]", "aria-hidden": "true") do
              render FlatPack::Shared::IconComponent.new(name: "chevron-down", size: :sm)
            end
          ])
        end
      end

      def control_classes
        [
          "flex items-center gap-2 w-full rounded-[var(--form-control-radius)]",
          "border border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "px-[var(--form-control-padding-x)] py-[var(--form-control-padding-y)]",
          "focus-within:ring-2 focus-within:ring-inset focus-within:ring-ring"
        ].join(" ")
      end

      def input_attributes
        {
          id: input_id,
          type: "text",
          value: selected_label,
          placeholder: @placeholder,
          autocomplete: "off",
          spellcheck: "false",
          disabled: @disabled,
          role: "combobox",
          aria: {
            expanded: "false",
            autocomplete: "list",
            controls: @list_id,
            haspopup: "listbox"
          },
          class: "min-w-0 flex-1 bg-transparent text-sm text-[var(--surface-content-color)] placeholder:text-[var(--surface-muted-content-color)] outline-none",
          data: {
            "flat-pack--combobox-target": "input",
            action: [
              "input->flat-pack--combobox#filter",
              "keydown->flat-pack--combobox#keydown",
              "focus->flat-pack--combobox#open"
            ].join(" ")
          }
        }
      end

      def render_hidden_field
        hidden_field_tag(
          @name,
          @value,
          required: @required,
          disabled: @disabled,
          data: {"flat-pack--combobox-target": "value"}
        )
      end

      def render_list
        content_tag(:ul, id: @list_id, **list_attributes) do
          safe_join(
            @options.each_with_index.map { |option, index| render_option(option, index) } + [
              render_status_row(@hint_text, "hint"),
              render_status_row(@loading_text, "loading"),
              render_empty_row
            ]
          )
        end
      end

      def list_attributes
        {
          role: "listbox",
          class: [
            "absolute z-40 mt-1 hidden max-h-60 w-full overflow-y-auto",
            "rounded-[var(--menu-radius)] border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)] shadow-md p-[var(--combobox-menu-padding)]"
          ].join(" "),
          data: {"flat-pack--combobox-target": "list"}
        }
      end

      def render_option(option, index)
        selected = option[:value] == @value
        content_tag(:li,
          option_inner(option),
          id: "#{@list_id}-option-#{index}",
          role: "option",
          class: option_classes(selected),
          data: option_data(option),
          aria: {selected: selected.to_s})
      end

      def option_data(option)
        data = {
          "flat-pack--combobox-target": "option",
          value: option[:value],
          label: option[:label],
          action: "mousedown->flat-pack--combobox#choose"
        }
        data[:subtitle] = option[:subtitle] if option[:subtitle].present?
        data
      end

      def option_inner(option)
        return option[:label] unless option[:subtitle].present?

        safe_join([
          content_tag(:span, option[:label], class: "block"),
          content_tag(:span, option[:subtitle], class: "block text-xs text-[var(--surface-muted-content-color)]")
        ])
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--list-item-hover-background-color)]" "bg-[var(--list-item-active-background-color)]"
      # "flex flex-col gap-0.5" "block text-xs text-[var(--surface-muted-content-color)]"
      def option_classes(selected)
        [
          "cursor-pointer rounded-[var(--dropdown-item-radius)] px-[var(--combobox-item-padding-x)] py-[var(--combobox-item-padding-y)] text-sm",
          "text-[var(--surface-content-color)]",
          "aria-selected:bg-[var(--list-item-active-background-color)]",
          selected ? "bg-[var(--list-item-active-background-color)]" : "hover:bg-[var(--list-item-hover-background-color)]"
        ].join(" ")
      end

      def render_status_row(text, target)
        content_tag(:li,
          text,
          class: "hidden px-[var(--combobox-item-padding-x)] py-[var(--combobox-item-padding-y)] text-sm text-[var(--surface-muted-content-color)]",
          data: {"flat-pack--combobox-target": target})
      end

      def render_empty_row
        content_tag(:li,
          @empty_text,
          class: "hidden px-[var(--combobox-item-padding-x)] py-[var(--combobox-item-padding-y)] text-sm text-[var(--surface-muted-content-color)]",
          data: {"flat-pack--combobox-target": "empty"})
      end

      def input_id
        "#{@name.to_s.parameterize}-combobox"
      end

      def validate_name!
        return if @name.present?

        raise ArgumentError, "name is required"
      end

      def validate_options!
        return if @options.any? || remote?

        raise ArgumentError, "options is required"
      end

      def validate_search_mode!
        return if SEARCH_MODES.include?(@search_mode)

        raise ArgumentError, "Invalid search_mode: #{@search_mode}. Must be one of: #{SEARCH_MODES.join(", ")}"
      end

      def validate_search_configuration!
        return unless remote?
        return if @search_endpoint.present?

        raise ArgumentError, "search_endpoint is required when search_mode is :remote"
      end

      def validate_search_endpoint!(raw_endpoint)
        return if @search_endpoint.present?

        raise ArgumentError, "Unsafe search_endpoint detected: #{raw_endpoint}"
      end
    end
  end
end
