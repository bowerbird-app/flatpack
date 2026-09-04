# frozen_string_literal: true

module FlatPack
  module Select
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles

      SEARCH_MODES = %i[local remote].freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"

      def initialize(
        name:,
        options:,
        value: nil,
        label: nil,
        placeholder: "Select an option",
        disabled: false,
        required: false,
        searchable: false,
        search_mode: :local,
        search_endpoint: nil,
        search_param: "q",
        min_search_length: 2,
        multiple: false,
        error: nil,
        help_text: nil,
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
        @search_mode = search_mode.to_sym
        @search_endpoint = search_endpoint.present? ? FlatPack::AttributeSanitizer.sanitize_url(search_endpoint) : nil
        @search_param = search_param.presence || "q"
        @min_search_length = [min_search_length.to_i, 1].max
        @multiple = multiple
        @error = error
        @help_text = normalize_help_text!(help_text)

        validate_name!
        validate_options!
        validate_search_mode!
        validate_search_configuration!
        validate_search_endpoint!(search_endpoint) if search_endpoint.present?
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: select_id,
          class: wrapper_classes
        ) do |field|
          field.with_control { render_select_wrapper }
        end
      end

      private

      def render_select_wrapper
        if @searchable || nested_options?
          render_custom_select
        else
          render_native_select
        end
      end

      def render_native_select
        content_tag(:div, class: "relative") do
          safe_join([
            tag.select(**select_attributes) do
              safe_join([
                render_placeholder_option,
                *@options.map { |option| render_option(option) }
              ].compact)
            end,
            render_chevron_icon(include_target: false)
          ])
        end
      end

      def render_custom_select
        content_tag(:div,
          class: "relative",
          data: {
            controller: "flat-pack--select",
            flat_pack__select_searchable_value: @searchable.to_s,
            flat_pack__select_search_mode_value: @search_mode,
            flat_pack__select_search_endpoint_value: @search_endpoint,
            flat_pack__select_search_param_value: @search_param,
            flat_pack__select_min_search_length_value: @min_search_length,
            flat_pack__select_multiple_value: @multiple.to_s,
            flat_pack__select_nested_value: nested_options?.to_s,
            flat_pack__select_options_value: (nested_options? ? @options.to_json : nil),
            flat_pack__select_input_name_value: hidden_input_name
          }) do
          safe_join([
            render_hidden_inputs,
            render_trigger_button,
            render_dropdown_menu
          ])
        end
      end

      def render_hidden_inputs
        return render_hidden_input unless @multiple

        content_tag(:div, data: {flat_pack__select_target: "hiddenInputs"}) do
          if selected_values.empty?
            tag.input(type: "hidden", name: hidden_input_name, id: select_id)
          else
            safe_join(selected_values.map.with_index { |selected_value, index| render_multi_hidden_input(selected_value, index) })
          end
        end
      end

      def render_hidden_input
        attrs = {
          type: "hidden",
          name: hidden_input_name,
          id: select_id,
          value: selected_values.first,
          required: @required,
          data: {flat_pack__select_target: "hiddenInput"}
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        tag.input(**apply_default_validation(attrs, error_id: error_id, has_error: @error.present?, type: "custom-select-hidden"))
      end

      def render_multi_hidden_input(selected_value, index)
        attrs = {
          type: "hidden",
          name: hidden_input_name,
          value: selected_value
        }

        attrs[:id] = select_id if index.zero?
        tag.input(**attrs)
      end

      def render_trigger_button
        selected_option = flat_options.find { |opt| selected_value?(opt[:value]) }
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
            expanded: "false",
            describedby: describedby_tokens((help_text_id if @help_text), (error_id if @error)).presence,
            invalid: (@error.present? ? "true" : nil)
          }) do
          @multiple ? render_multiselect_trigger_content : safe_join([
            content_tag(:span, display_text, class: "block truncate"),
            render_chevron_icon
          ])
        end
      end

      def render_multiselect_trigger_content
        selected_labels = flat_options.select { |option| selected_value?(option[:value]) }

        safe_join([
          content_tag(:span,
            @placeholder,
            class: selected_labels.any? ? "hidden block truncate" : "block truncate",
            data: {flat_pack__select_target: "placeholder"}),
          content_tag(:span, class: "flex flex-wrap gap-1 pr-6", data: {flat_pack__select_target: "chipsContainer"}) do
            safe_join(flat_options.map { |option| render_trigger_chip(option) })
          end,
          render_chevron_icon
        ])
      end

      def render_trigger_chip(option)
        selected = selected_value?(option[:value])
        chip = FlatPack::Chip::Component.new(text: option[:label], size: :sm)
        chip.trailing do
          content_tag(:span,
            class: "inline-flex items-center justify-center cursor-pointer rounded-full",
            role: "button",
            tabindex: "0",
            aria: {label: "Remove #{option[:label]}"},
            data: {
              action: "click->flat-pack--select#removeChip keydown->flat-pack--select#removeChipKeydown",
              value: option[:value]
            }) do
            render FlatPack::Shared::IconComponent.new(name: "x-mark", size: :sm)
          end
        end

        content_tag(:span,
          class: classes("hidden" => !selected),
          data: {
            flat_pack__select_target: "chip",
            value: option[:value]
          }) do
          render chip
        end
      end

      def render_dropdown_menu
        content_tag(:div,
          class: dropdown_classes,
          data: {flat_pack__select_target: "dropdown"},
          role: "listbox") do
          safe_join([
            render_search_input,
            render_options_list,
            render_search_status
          ].compact)
        end
      end

      def render_search_input
        return unless @searchable

        content_tag(:div, class: "p-2 border-b border-[var(--surface-border-color)]") do
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
        content_tag(:div,
          class: "max-h-60 overflow-y-auto p-1 data-[results-count='0']:hidden",
          data: {
            flat_pack__select_target: "optionsList",
            results_count: flat_options.length
          }) do
          if nested_options?
            safe_join(@options.map { |option| render_nested_custom_option_group(option) })
          else
            safe_join(@options.map { |option| render_custom_option(option) })
          end
        end
      end

      def render_search_status
        return unless remote_search?

        content_tag(:div,
          class: "hidden px-3 py-2 text-sm text-[var(--surface-muted-content-color)]",
          data: {flat_pack__select_target: "searchStatus"}) do
          safe_join([
            content_tag(:p, "Type at least #{@min_search_length} characters to search", class: "hidden", data: {flat_pack__select_target: "searchHint"}),
            content_tag(:p, "Searching...", class: "hidden", data: {flat_pack__select_target: "loadingState"}),
            content_tag(:p, "No options found", class: "hidden", data: {flat_pack__select_target: "emptyState"})
          ])
        end
      end

      def render_custom_option(option)
        selected = selected_value?(option[:value])

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

      def render_nested_custom_option_group(option)
        safe_join([
          render_nested_custom_option(option, type: "parent", parent_value: option[:value]),
          safe_join(option[:children].map { |child| render_nested_custom_option(child, type: "child", parent_value: option[:value]) })
        ])
      end

      def render_nested_custom_option(option, type:, parent_value:)
        selected = selected_value?(option[:value])
        child = type == "child"

        content_tag(:div,
          class: nested_custom_option_classes(selected, option[:disabled], child),
          role: "option",
          data: {
            action: "click->flat-pack--select#selectNestedOption",
            value: option[:value],
            label: option[:label],
            disabled: option[:disabled],
            parent_value: parent_value,
            option_type: type
          },
          aria: {selected: selected.to_s}) do
          safe_join([
            tag.input(
              type: "checkbox",
              checked: selected,
              disabled: option[:disabled],
              tabindex: "-1",
              class: "h-4 w-4 rounded border-[var(--surface-border-color)] text-[var(--color-primary)] accent-[var(--color-primary)] pointer-events-none",
              data: {flat_pack__select_target: "nestedCheckbox"},
              aria: {hidden: "true"}
            ),
            content_tag(:span, option[:label], class: child ? "text-sm" : "font-medium")
          ])
        end
      end

      def render_placeholder_option
        return if @multiple
        return unless @placeholder

        content_tag(:option, @placeholder, value: "", disabled: true, selected: @value.nil? || @value.to_s.empty?)
      end

      def render_option(option)
        content_tag(:option,
          option[:label],
          value: option[:value],
          selected: selected_value?(option[:value]),
          disabled: option[:disabled])
      end

      def render_chevron_icon(include_target: true)
        icon_data = include_target ? {flat_pack__select_target: "chevron"} : nil

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
            class: "lucide lucide-chevron-down text-[var(--surface-muted-content-color)]",
            data: icon_data) do
            tag.path(d: "m6 9 6 6 6-6")
          end
        end
      end

      def select_attributes
        attrs = {
          name: select_name,
          id: select_id,
          disabled: @disabled,
          required: @required,
          multiple: @multiple,
          class: select_classes
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def wrapper_classes
        "flat-pack-select-wrapper"
      end

      def select_classes
        form_control_classes(
          error: @error,
          custom_class: @custom_class,
          control_class: "flat-pack-select",
          appearance_none: true,
          placeholder: false,
          extra: ["pr-10"]
        )
      end

      def trigger_classes
        form_control_classes(
          error: @error,
          custom_class: @custom_class,
          control_class: "flat-pack-select-trigger",
          placeholder: false,
          extra: ["relative", "pr-10", "text-left"]
        )
      end

      def dropdown_classes
        "absolute z-10 mt-1 w-full hidden rounded-[var(--radius-md)] border border-[var(--surface-border-color)] bg-[var(--surface-background-color)] shadow-lg"
      end

      def search_input_classes
        "w-full px-[var(--form-control-padding)] py-[var(--form-control-padding)] text-sm rounded-[var(--radius-sm)] border border-[var(--surface-border-color)] bg-[var(--surface-background-color)] text-[var(--surface-content-color)] focus:outline-none focus:ring-1 focus:ring-inset focus:ring-ring"
      end

      def custom_option_classes(selected, disabled)
        base = [
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "rounded-[var(--radius-sm)]",
          "transition-colors duration-base"
        ]

        base << if disabled
          "opacity-50 cursor-not-allowed text-[var(--surface-muted-content-color)]"
        elsif selected
          if @multiple
            "hover:bg-[var(--surface-muted-background-color)] cursor-pointer text-[var(--surface-content-color)]"
          else
            "bg-[var(--color-primary)] text-white cursor-pointer"
          end
        else
          "hover:bg-[var(--surface-muted-background-color)] cursor-pointer text-[var(--surface-content-color)]"
        end

        base.join(" ")
      end

      def nested_custom_option_classes(selected, disabled, child)
        base = [
          "flex items-center gap-2",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "rounded-none",
          "transition-colors duration-base"
        ]

        base << "ml-6 border-l border-[var(--surface-border-color)] pl-4" if child

        base << if disabled
          "opacity-50 cursor-not-allowed text-[var(--surface-muted-content-color)]"
        elsif selected
          "hover:bg-[var(--surface-muted-background-color)] cursor-pointer text-[var(--surface-content-color)]"
        else
          "hover:bg-[var(--surface-muted-background-color)] cursor-pointer text-[var(--surface-content-color)]"
        end

        base.join(" ")
      end

      def select_id
        @select_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{select_id}_error"
      end

      def help_text_id
        "#{select_id}_help_text"
      end

      def selected_values
        @selected_values ||= begin
          values = @multiple ? Array(@value) : Array(@value).first(1)
          values = values.compact.map(&:to_s).reject(&:empty?)
          nested_options? ? normalized_nested_selected_values(values) : values
        end
      end

      def selected_value?(value)
        selected_values.include?(value.to_s)
      end

      def select_name
        return @name unless @multiple
        return @name if @name.end_with?("[]")

        "#{@name}[]"
      end

      def hidden_input_name
        select_name
      end

      def remote_search?
        @searchable && @search_mode == :remote
      end

      def nested_options?
        @multiple && @options.any? { |option| option[:children].present? }
      end

      def flat_options
        @flat_options ||= @options.flat_map { |option| [option, *option.fetch(:children, [])] }
      end

      def normalized_nested_selected_values(values)
        selected = values.to_set

        @options.each do |parent|
          enabled_children = parent.fetch(:children, []).reject { |child| child[:disabled] }

          if selected.include?(parent[:value])
            enabled_children.each { |child| selected.add(child[:value]) }
          elsif enabled_children.any? && enabled_children.all? { |child| selected.include?(child[:value]) }
            selected.add(parent[:value])
          else
            selected.delete(parent[:value])
          end
        end

        ordered_values(selected)
      end

      def ordered_values(selected)
        ordered = []

        @options.each do |parent|
          ordered << parent[:value] if selected.include?(parent[:value])

          parent.fetch(:children, []).each do |child|
            ordered << child[:value] if selected.include?(child[:value])
          end
        end

        selected.each { |value| ordered << value unless ordered.include?(value) }
        ordered
      end

      def normalize_options(options)
        return [] if options.nil?

        options.map do |option|
          case option
          when String
            {label: option, value: option, disabled: false, children: []}
          when Array
            {label: option[0].to_s, value: option[1].to_s, disabled: false, children: []}
          when Hash
            normalize_hash_option(option)
          else
            raise ArgumentError, "Invalid option format: #{option.inspect}"
          end
        end
      end

      def normalize_hash_option(option)
        value = option[:value] || option["value"] || option[:id] || option["id"]
        label = option[:label] || option["label"] || value
        children = option[:children] || option["children"] || []

        {
          label: label.to_s,
          value: value.to_s,
          disabled: option[:disabled] || option["disabled"] || false,
          children: Array(children).map { |child| normalize_child_option(child) }
        }
      end

      def normalize_child_option(option)
        case option
        when String
          {label: option, value: option, disabled: false}
        when Array
          {label: option[0].to_s, value: option[1].to_s, disabled: false}
        when Hash
          value = option[:value] || option["value"] || option[:id] || option["id"]
          label = option[:label] || option["label"] || value

          {
            label: label.to_s,
            value: value.to_s,
            disabled: option[:disabled] || option["disabled"] || false
          }
        else
          raise ArgumentError, "Invalid option format: #{option.inspect}"
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_options!
        raise ArgumentError, "options is required" if @raw_options.nil?
        raise ArgumentError, "options must be an array" unless @raw_options.is_a?(Array)
      end

      def validate_search_mode!
        return if SEARCH_MODES.include?(@search_mode)

        raise ArgumentError, "Invalid search_mode: #{@search_mode}. Must be one of: #{SEARCH_MODES.join(", ")}"
      end

      def validate_search_configuration!
        return unless remote_search?
        return if @search_endpoint.present?

        raise ArgumentError, "search_endpoint is required when search_mode is :remote"
      end

      def validate_search_endpoint!(raw_endpoint)
        raise ArgumentError, "Unsafe search_endpoint detected: #{raw_endpoint}" if @search_endpoint.nil?
      end
    end
  end
end
