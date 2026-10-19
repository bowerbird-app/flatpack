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
        placeholder: FlatPack::Copy::OMITTED,
        name: "q",
        value: nil,
        search_url: nil,
        items: nil,
        max_width: :md,
        size: :md,
        min_characters: 2,
        debounce: 250,
        no_results_text: FlatPack::Copy::OMITTED,
        collapsible: false,
        collapsed: true,
        grow: :end,
        **system_arguments
      )
        super(**system_arguments)
        @placeholder = fp_text(placeholder, "search.placeholder")
        @name = name
        @value = value
        @search_url = search_url.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_url) : nil
        @items = normalize_items(items)
        @max_width = max_width.to_sym
        @size = size.to_sym
        @min_characters = min_characters
        @debounce = debounce
        @no_results_text = fp_text(no_results_text, "search.no_results")
        @collapse = Collapse.resolve(collapsible: collapsible, collapsed: collapsed, grow: grow, value: @value)
        @generated_input_id = "fp-search-#{SecureRandom.hex(4)}" if @collapse.active?

        validate_search_url!(search_url) if search_url.present?
        validate_max_width!
        validate_size!
      end

      def call
        @collapse.active? ? render_collapsible : render_field
      end

      private

      def render_field
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_icon,
            render_input,
            render_clear_button,
            (render_dropdown if live_search?)
          ].compact)
        end
      end

      def render_collapsible
        content_tag(:div, **collapsible_wrapper_attributes) do
          safe_join([
            render_toggle,
            content_tag(:div, **field_attributes) do
              safe_join([render_icon, render_input, render_clear_button].compact)
            end,
            (render_dropdown if live_search?)
          ].compact)
        end
      end

      def render_toggle
        options = {
          text: toggle_label,
          icon: :search,
          icon_only: true,
          round: true,
          size: @size,
          type: "button",
          class: "fp-search__toggle",
          data: {
            flat_pack__search_collapse_target: "toggle",
            action: "click->flat-pack--search-collapse#expand"
          },
          aria: {
            expanded: (@collapse.collapsed? ? "false" : "true"),
            controls: input_control_id
          }
        }
        options[:inert] = true unless @collapse.collapsed?

        render FlatPack::Button::Component.new(**options)
      end

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
          aria: {label: fp_t("search.clear")}) do
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

        attrs[:data].merge!(live_search_data)

        merge_attributes(**attrs)
      end

      def collapsible_wrapper_attributes
        attrs = {
          class: collapsible_wrapper_classes,
          data: merge_data_attributes(data_attributes, {
            controller: classes("flat-pack--search-collapse", wrapper_controller_names),
            action: "focusout->flat-pack--search-collapse#dismiss",
            flat_pack__search_collapse_collapsed_value: @collapse.collapsed?,
            fp_collapsed: @collapse.collapsed?.to_s,
            fp_grow: @collapse.grow.to_s,
            fp_size: @size.to_s
          })
        }
        attrs[:data].merge!(live_search_data)

        merged = merge_attributes(**attrs)
        label = merged[:aria]
        return merged unless label.is_a?(Hash)

        stripped = label.except(:label, "label")
        stripped.empty? ? merged.except(:aria) : merged.merge(aria: stripped)
      end

      def collapsible_wrapper_classes
        classes(
          "fp-search",
          "fp-search--collapsible",
          "relative",
          "flex",
          "items-center",
          "min-w-0",
          "max-w-full",
          max_width_class
        )
      end

      def field_attributes
        attrs = {
          class: "fp-search__field min-w-0 w-full",
          data: {flat_pack__search_collapse_target: "field"}
        }
        attrs[:inert] = true if @collapse.collapsed?
        attrs
      end

      def live_search_data
        return {} unless live_search?

        {
          flat_pack__search_url_value: @search_url,
          flat_pack__search_param_value: @name,
          flat_pack__search_min_characters_value: @min_characters,
          flat_pack__search_debounce_value: @debounce,
          flat_pack__search_items_value: @items
        }
      end

      def toggle_label
        explicit = aria_attributes[:label].presence || aria_attributes["label"].presence
        explicit || fp_t("common.search")
      end

      def input_control_id
        return unless @collapse.active?

        host_id = html_attributes[:id].presence
        host_id ? "#{host_id}-field" : @generated_input_id
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
          icon_inset_class,
          "flex",
          "items-center",
          "pointer-events-none",
          "text-[var(--search-icon-color)]"
        )
      end

      def icon_inset_class
        insets = grow_toward_start? ? CLEAR_INSET_CLASSES : ICON_INSET_CLASSES
        insets.fetch(@size)
      end

      def clear_inset_class
        insets = grow_toward_start? ? ICON_INSET_CLASSES : CLEAR_INSET_CLASSES
        insets.fetch(@size)
      end

      def grow_toward_start?
        @collapse.active? && @collapse.grow == :start
      end

      def input_attributes
        input_data = {
          flat_pack__search_input_target: "input",
          action: input_action
        }
        input_data[:flat_pack__search_collapse_target] = "input" if @collapse.active?

        attrs = {
          type: "text",
          name: @name,
          value: @value,
          placeholder: @placeholder,
          class: input_classes,
          data: input_data
        }
        attrs[:id] = input_control_id if @collapse.active?

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
          ("min-w-0" if @collapse.active?),
          size_classes,
          "bg-[var(--search-input-background-color)]",
          "text-[var(--search-input-text-color)]",
          "border",
          "border-[var(--search-input-border-color)]",
          "rounded-[var(--form-control-radius)]",
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
          clear_inset_class,
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
            content_tag(:div, @no_results_text, class: "hidden px-[var(--search-result-padding-x)] py-[var(--search-result-padding-y)] text-sm text-[var(--search-dropdown-muted-text-color)]", data: {flat_pack__search_target: "noResults"}),
            content_tag(:div, fp_t("search.searching"), class: "hidden px-[var(--search-result-padding-x)] py-[var(--search-result-padding-y)] text-sm text-[var(--search-dropdown-muted-text-color)]", data: {flat_pack__search_target: "loading"})
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
            "rounded-[var(--menu-radius)]",
            "border",
            "border-[var(--search-dropdown-border-color)]",
            "bg-[var(--search-dropdown-background-color)]",
            "shadow-sm",
            "overflow-hidden",
            "p-[var(--search-menu-padding)]"
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
