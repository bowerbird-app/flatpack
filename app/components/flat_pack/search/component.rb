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

      def initialize(
        placeholder: "Search...",
        name: "q",
        value: nil,
        search_url: nil,
        max_width: :md,
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
        @max_width = max_width.to_sym
        @min_characters = min_characters
        @debounce = debounce
        @no_results_text = no_results_text

        validate_search_url!(search_url) if search_url.present?
        validate_max_width!
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
            size: :sm
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
            size: :sm
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
            flat_pack__search_debounce_value: @debounce
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
          "left-3",
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
          "pl-10",
          "pr-10",
          "py-2",
          "text-sm",
          "bg-[var(--search-input-background-color)]",
          "text-[var(--search-input-text-color)]",
          "border",
          "border-[var(--search-input-border-color)]",
          "rounded-lg",
          "focus:outline-none",
          "focus:ring-2",
          "focus:ring-inset",
          "focus:ring-[var(--search-input-focus-ring-color)]",
          "focus:border-transparent",
          "placeholder:text-[var(--search-input-placeholder-color)]"
        )
      end

      def clear_button_classes
        classes(
          "absolute",
          "right-3",
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
            "rounded-lg",
            "border",
            "border-[var(--search-dropdown-border-color)]",
            "bg-[var(--search-dropdown-background-color)]",
            "shadow-sm"
          ),
          data: {
            flat_pack__search_target: "dropdown"
          }
        }
      end

      def live_search?
        @search_url.present?
      end

      def validate_search_url!(original_url)
        return if @search_url.present?

        raise ArgumentError, "Unsafe search_url detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end

      def validate_max_width!
        return if MAX_WIDTH_CLASSES.key?(@max_width)

        raise ArgumentError, "Invalid max_width: #{@max_width}. Must be one of: #{MAX_WIDTH_CLASSES.keys.join(", ")}."
      end
    end
  end
end
