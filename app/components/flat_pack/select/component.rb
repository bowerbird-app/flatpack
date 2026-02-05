# frozen_string_literal: true

module FlatPack
  module Select
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"

      def initialize(
        name:,
        options:,
        value: nil,
        label: nil,
        placeholder: "Select an option",
        disabled: false,
        required: false,
        searchable: false,
        error: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @raw_options = options
        @options = normalize_options(options)
        @value = value
        @label = label
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @searchable = searchable
        @error = error

        validate_name!
        validate_options!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_select_wrapper,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(select_id, @label, class: label_classes)
      end

      def render_select_wrapper
        if @searchable
          render_custom_select
        else
          render_native_select
        end
      end

      def render_native_select
        tag.select(**select_attributes) do
          safe_join([
            render_placeholder_option,
            *@options.map { |option| render_option(option) }
          ].compact)
        end
      end

      def render_custom_select
        content_tag(:div,
          class: "relative",
          data: {
            controller: "flat-pack--select",
            flat_pack__select_searchable_value: @searchable.to_s
          }) do
          safe_join([
            render_hidden_input,
            render_trigger_button,
            render_dropdown_menu
          ])
        end
      end

      def render_hidden_input
        tag.input(
          type: "hidden",
          name: @name,
          value: @value,
          data: {flat_pack__select_target: "hiddenInput"}
        )
      end

      def render_trigger_button
        selected_option = @options.find { |opt| opt[:value].to_s == @value.to_s }
        display_text = selected_option ? selected_option[:label] : @placeholder

        content_tag(:button,
          type: "button",
          class: trigger_classes,
          disabled: @disabled,
          data: {
            action: "flat-pack--select#toggle",
            flat_pack__select_target: "trigger"
          },
          aria: {
            haspopup: "listbox",
            expanded: "false"
          }) do
          safe_join([
            content_tag(:span, display_text, class: "block truncate"),
            render_chevron_icon
          ])
        end
      end

      def render_dropdown_menu
        content_tag(:div,
          class: dropdown_classes,
          data: {flat_pack__select_target: "dropdown"},
          role: "listbox") do
          safe_join([
            render_search_input,
            render_options_list
          ].compact)
        end
      end

      def render_search_input
        return unless @searchable

        content_tag(:div, class: "p-2 border-b border-[var(--color-border)]") do
          tag.input(
            type: "text",
            class: search_input_classes,
            placeholder: "Search...",
            data: {
              action: "input->flat-pack--select#search",
              flat_pack__select_target: "searchInput"
            }
          )
        end
      end

      def render_options_list
        content_tag(:div, class: "max-h-60 overflow-y-auto p-1", data: {flat_pack__select_target: "optionsList"}) do
          safe_join(@options.map { |option| render_custom_option(option) })
        end
      end

      def render_custom_option(option)
        selected = @value.to_s == option[:value].to_s

        content_tag(:div,
          option[:label],
          class: custom_option_classes(selected, option[:disabled]),
          role: "option",
          data: {
            action: "click->flat-pack--select#selectOption",
            value: option[:value],
            label: option[:label],
            disabled: option[:disabled]
          },
          aria: {selected: selected.to_s})
      end

      def render_placeholder_option
        return unless @placeholder

        content_tag(:option, @placeholder, value: "", disabled: true, selected: @value.nil? || @value.to_s.empty?)
      end

      def render_option(option)
        content_tag(:option,
          option[:label],
          value: option[:value],
          selected: @value.to_s == option[:value].to_s,
          disabled: option[:disabled])
      end

      def render_chevron_icon
        content_tag(:span, class: "absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none") do
          content_tag(:svg,
            xmlns: "http://www.w3.org/2000/svg",
            width: "16",
            height: "16",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2",
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            class: "lucide lucide-chevron-down text-[var(--color-muted-foreground)]",
            data: {flat_pack__select_target: "chevron"}) do
            tag.path(d: "m6 9 6 6 6-6")
          end
        end
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def select_attributes
        attrs = {
          name: @name,
          id: select_id,
          disabled: @disabled,
          required: @required,
          class: select_classes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**attrs.compact)
      end

      def wrapper_classes
        "flat-pack-select-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--color-foreground)] mb-1.5"
        )
      end

      def select_classes
        base_classes = [
          "flat-pack-select",
          "w-full",
          "rounded-[var(--radius-md)]",
          "border",
          "bg-[var(--color-background)]",
          "text-[var(--color-foreground)]",
          "px-3 py-2",
          "pr-10",
          "text-sm",
          "transition-colors duration-[var(--transition-base)]",
          "focus:outline-none focus:ring-2 focus:ring-[var(--color-ring)] focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--color-border)]"
        end

        classes(*base_classes, @custom_class)
      end

      def trigger_classes
        base_classes = [
          "flat-pack-select-trigger",
          "relative w-full",
          "rounded-[var(--radius-md)]",
          "border",
          "bg-[var(--color-background)]",
          "text-[var(--color-foreground)]",
          "px-3 py-2",
          "pr-10",
          "text-sm text-left",
          "transition-colors duration-[var(--transition-base)]",
          "focus:outline-none focus:ring-2 focus:ring-[var(--color-ring)] focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--color-border)]"
        end

        classes(*base_classes, @custom_class)
      end

      def dropdown_classes
        "absolute z-10 mt-1 w-full hidden rounded-[var(--radius-md)] border border-[var(--color-border)] bg-[var(--color-background)] shadow-lg"
      end

      def search_input_classes
        "w-full px-2 py-1.5 text-sm rounded-[var(--radius-sm)] border border-[var(--color-border)] bg-[var(--color-background)] text-[var(--color-foreground)] focus:outline-none focus:ring-1 focus:ring-[var(--color-ring)]"
      end

      def custom_option_classes(selected, disabled)
        base = [
          "px-3 py-2",
          "text-sm",
          "rounded-[var(--radius-sm)]",
          "transition-colors duration-[var(--transition-base)]"
        ]

        base << if disabled
          "opacity-50 cursor-not-allowed text-[var(--color-muted-foreground)]"
        elsif selected
          "bg-[var(--color-primary)] text-white cursor-pointer"
        else
          "hover:bg-[var(--color-muted)] cursor-pointer text-[var(--color-foreground)]"
        end

        base.join(" ")
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-warning)]"
      end

      def select_id
        @select_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{select_id}_error"
      end

      def normalize_options(options)
        return [] if options.nil?

        options.map do |option|
          case option
          when String
            {label: option, value: option, disabled: false}
          when Array
            {label: option[0], value: option[1], disabled: false}
          when Hash
            {
              label: option[:label] || option["label"],
              value: option[:value] || option["value"],
              disabled: option[:disabled] || option["disabled"] || false
            }
          else
            raise ArgumentError, "Invalid option format: #{option.inspect}"
          end
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_options!
        raise ArgumentError, "options is required" if @raw_options.nil?
        raise ArgumentError, "options must be an array" unless @raw_options.is_a?(Array)
      end
    end
  end
end
