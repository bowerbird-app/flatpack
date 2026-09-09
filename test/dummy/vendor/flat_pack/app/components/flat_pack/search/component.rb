# frozen_string_literal: true

module FlatPack
  module Search
    class Component < FlatPack::BaseComponent
      MAX_WIDTH_CLASSES = {
        none: "max-w-none",
        md: "max-w-md",
        lg: "max-w-lg",
        xl: "max-w-xl"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "py-[var(--search-padding-y-sm)]" "pl-[var(--search-padding-inline-sm)]" "pr-[var(--search-padding-inline-sm)]" "text-xs"
      # "py-[var(--search-padding-y-md)]" "pl-[var(--search-padding-inline-md)]" "pr-[var(--search-padding-inline-md)]" "text-sm"
      # "py-[var(--search-padding-y-lg)]" "pl-[var(--search-padding-inline-lg)]" "pr-[var(--search-padding-inline-lg)]" "text-base"
      # "left-2" "left-3" "left-4" "right-2" "right-3" "right-4"
      SIZES = {
        sm: "py-[var(--search-padding-y-sm)] pl-[var(--search-padding-inline-sm)] pr-[var(--search-padding-inline-sm)] text-xs",
        md: "py-[var(--search-padding-y-md)] pl-[var(--search-padding-inline-md)] pr-[var(--search-padding-inline-md)] text-sm",
        lg: "py-[var(--search-padding-y-lg)] pl-[var(--search-padding-inline-lg)] pr-[var(--search-padding-inline-lg)] text-base"
      }.freeze

      ICON_SIZES = {
        sm: :sm,
        md: :sm,
        lg: :md
      }.freeze

      ICON_INSET_CLASSES = {
        sm: "left-2",
        md: "left-3",
        lg: "left-4"
      }.freeze

      CLEAR_INSET_CLASSES = {
        sm: "right-2",
        md: "right-3",
        lg: "right-4"
      }.freeze

      def initialize(
        placeholder: "Search...",
        name: "q",
        value: nil,
        search_url: nil,
        items: nil,
        max_width: :md,
        size: :md,
        min_characters: 2,
        debounce: 250,
        no_results_text: "No results found",
        **system_arguments
      )
        super(**system_arguments)
        @placeholder = placeholder
        @name = name
        @value = value
        @search_url = search_url.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_url) : nil
        @items = normalize_items(items)
        @max_width = max_width.to_sym
        @size = size.to_sym
        @min_characters = min_characters
        @debounce = debounce
        @no_results_text = no_results_text

        validate_search_url!(search_url) if search_url.present?
        validate_max_width!
        validate_size!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_icon,
            render_input,
            render_clear_button,
            (render_dropdown if live_search?)
          ].compact)
        end
      end

      private

      def render_icon
        content_tag(:span, class: icon_wrapper_classes) do
          render FlatPack::Shared::IconComponent.new(
            name: :search,
            size: icon_size
          )
        end
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_clear_button
        content_tag(:button,
          type: "button",
          class: clear_button_classes,
          data: {
            action: "flat-pack--search-input#clear",
            flat_pack__search_input_target: "clearButton"
          },
          aria: {label: "Clear search"}) do
          render FlatPack::Shared::IconComponent.new(
            name: "x-mark",
            size: icon_size
          )
        end
      end

      def wrapper_attributes
        attrs = {
          class: wrapper_classes,
          data: {
            controller: wrapper_controller_names
          }
        }

        if live_search?
          attrs[:data].merge!(
            flat_pack__search_url_value: @search_url,
            flat_pack__search_param_value: @name,
            flat_pack__search_min_characters_value: @min_characters,
            flat_pack__search_debounce_value: @debounce,
            flat_pack__search_items_value: @items
          )
        end

        merge_attributes(**attrs)
      end

      def wrapper_classes
        classes(
          "relative",
          "flex",
          "items-center",
          "w-full",
          max_width_class
        )
      end

      def max_width_class
        MAX_WIDTH_CLASSES.fetch(@max_width)
      end

      def icon_wrapper_classes
        classes(
          "absolute",
          "inset-y-0",
          ICON_INSET_CLASSES.fetch(@size),
          "flex",
          "items-center",
          "pointer-events-none",
          "text-[var(--search-icon-color)]"
        )
      end

      def input_attributes
        attrs = {
          type: "text",
          name: @name,
          value: @value,
          placeholder: @placeholder,
          class: input_classes,
          data: {
            flat_pack__search_input_target: "input",
            action: input_action
          }
        }

        if live_search?
          attrs[:autocomplete] = "off"
          attrs[:data][:flat_pack__search_target] = "input"
          attrs[:aria] = {
            haspopup: "listbox",
            expanded: "false"
          }
        end

        merge_attributes(**attrs.compact)
      end

      def input_classes
        classes(
          "w-full",
          size_classes,
          "bg-[var(--search-input-background-color)]",
          "text-[var(--search-input-text-color)]",
          "border",
          "border-[var(--search-input-border-color)]",
          "rounded-[var(--radius-lg)]",
          "focus:outline-none",
          "focus:ring-2",
          "focus:ring-inset",
          "focus:ring-[var(--search-input-focus-ring-color)]",
          "focus:border-transparent",
          "placeholder:text-[var(--search-input-placeholder-color)]"
        )
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def icon_size
        ICON_SIZES.fetch(@size)
      end

      def clear_button_classes
        classes(
          "absolute",
          CLEAR_INSET_CLASSES.fetch(@size),
          "top-1/2",
          "-translate-y-1/2",
          "h-full",
          "leading-none",
          "cursor-pointer",
          "text-[var(--search-icon-color)]",
          "transition-colors",
          "hover:text-[var(--search-input-text-color)]",
          ("hidden" unless @value.present?)
        )
      end

      def wrapper_controller_names
        classes(
          "flat-pack--search-input",
          ("flat-pack--search" if live_search?)
        )
      end

      def input_action
        classes(
          "input->flat-pack--search-input#toggleClearButton",
          ("input->flat-pack--search#search keydown->flat-pack--search#handleKeydown" if live_search?)
        )
      end

      def render_dropdown
        content_tag(:div, **dropdown_attributes) do
          safe_join([
            content_tag(:ul, "", class: "max-h-72 overflow-y-auto", data: {flat_pack__search_target: "results"}, role: "listbox"),
            content_tag(:div, @no_results_text, class: "hidden px-3 py-3 text-sm text-[var(--search-dropdown-muted-text-color)]", data: {flat_pack__search_target: "noResults"}),
            content_tag(:div, "Searching...", class: "hidden px-3 py-3 text-sm text-[var(--search-dropdown-muted-text-color)]", data: {flat_pack__search_target: "loading"})
          ])
        end
      end

      def dropdown_attributes
        {
          class: classes(
            "hidden",
            "absolute",
            "left-0",
            "right-0",
            "top-full",
            "mt-2",
            "z-20",
            "rounded-[var(--radius-lg)]",
            "border",
            "border-[var(--search-dropdown-border-color)]",
            "bg-[var(--search-dropdown-background-color)]",
            "shadow-sm",
            "overflow-hidden"
          ),
          data: {
            flat_pack__search_target: "dropdown"
          }
        }
      end

      def live_search?
        @search_url.present? || @items.any?
      end

      def normalize_items(items)
        Array(items).filter_map do |item|
          next unless item.respond_to?(:to_h)

          hash = item.to_h
          title = hash[:title] || hash["title"]
          next if title.blank?

          {
            title: title.to_s,
            description: (hash[:description] || hash["description"]).to_s.presence,
            url: hash[:url] || hash["url"]
          }.compact
        end
      end

      def validate_search_url!(original_url)
        return if @search_url.present?

        raise ArgumentError, "Unsafe search_url detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end

      def validate_max_width!
        return if MAX_WIDTH_CLASSES.key?(@max_width)

        raise ArgumentError, "Invalid max_width: #{@max_width}. Must be one of: #{MAX_WIDTH_CLASSES.keys.join(", ")}."
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}."
      end
    end
  end
end
