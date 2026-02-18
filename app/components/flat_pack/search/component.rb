# frozen_string_literal: true

module FlatPack
  module Search
    class Component < FlatPack::BaseComponent
      def initialize(
        placeholder: "Search...",
        name: "q",
        value: nil,
        search_url: nil,
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
        @min_characters = min_characters
        @debounce = debounce
        @no_results_text = no_results_text

        validate_search_url!(search_url) if search_url.present?
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_icon,
            render_input,
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

      def wrapper_attributes
        attrs = {
          class: wrapper_classes
        }

        if live_search?
          attrs[:data] = {
            controller: "flat-pack--search",
            flat_pack__search_url_value: @search_url,
            flat_pack__search_param_value: @name,
            flat_pack__search_min_characters_value: @min_characters,
            flat_pack__search_debounce_value: @debounce
          }
        end

        merge_attributes(**attrs)
      end

      def wrapper_classes
        classes(
          "relative",
          "flex",
          "items-center",
          "w-full",
          "max-w-md"
        )
      end

      def icon_wrapper_classes
        classes(
          "absolute",
          "left-3",
          "pointer-events-none",
          "text-[var(--color-text-muted)]"
        )
      end

      def input_attributes
        attrs = {
          type: "text",
          name: @name,
          value: @value,
          placeholder: @placeholder,
          class: input_classes
        }

        if live_search?
          attrs[:autocomplete] = "off"
          attrs[:data] = {
            flat_pack__search_target: "input",
            action: "input->flat-pack--search#search focus->flat-pack--search#open keydown->flat-pack--search#handleKeydown"
          }
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
          "pr-4",
          "py-2",
          "text-sm",
          "bg-[var(--color-muted)]",
          "border",
          "border-transparent",
          "rounded-lg",
          "focus:outline-none",
          "focus:ring-2",
          "focus:ring-[var(--color-primary)]",
          "focus:border-transparent",
          "placeholder:text-[var(--color-text-muted)]"
        )
      end

      def render_dropdown
        content_tag(:div, **dropdown_attributes) do
          safe_join([
            content_tag(:ul, "", class: "max-h-72 overflow-y-auto", data: {flat_pack__search_target: "results"}, role: "listbox"),
            content_tag(:div, @no_results_text, class: "hidden px-3 py-3 text-sm text-[var(--color-text-muted)]", data: {flat_pack__search_target: "noResults"}),
            content_tag(:div, "Searching...", class: "hidden px-3 py-3 text-sm text-[var(--color-text-muted)]", data: {flat_pack__search_target: "loading"})
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
            "border-[var(--color-border)]",
            "bg-[var(--color-background)]",
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
    end
  end
end
