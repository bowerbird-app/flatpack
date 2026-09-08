# frozen_string_literal: true

module FlatPack
  module Combobox
    class Component < FlatPack::BaseComponent
      def initialize(
        name:,
        options:,
        value: nil,
        label: nil,
        placeholder: "Search",
        disabled: false,
        required: false,
        empty_text: "No matches",
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @options = normalize_options(options)
        @value = value.to_s.presence
        @label = label
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @empty_text = empty_text
        @list_id = "fp-combobox-#{SecureRandom.hex(4)}"
        validate_name!
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
              label: (option[:label] || option[:value]).to_s
            }
          else
            {value: option.to_s, label: option.to_s}
          end
        end
      end

      def selected_label
        match = @options.find { |option| option[:value] == @value }
        match ? match[:label] : @value
      end

      def root_attributes
        merge_attributes(
          class: "relative w-full",
          data: {
            controller: "flat-pack--combobox",
            "flat-pack--combobox-empty-text-value": @empty_text
          }
        )
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
          "flex items-center gap-2 w-full rounded-[var(--radius-md)]",
          "border border-[var(--surface-border-color)]",
          "bg-[var(--surface-background-color)]",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
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
          safe_join(@options.each_with_index.map { |option, index| render_option(option, index) } + [render_empty_row])
        end
      end

      def list_attributes
        {
          role: "listbox",
          class: [
            "absolute z-40 mt-1 hidden max-h-60 w-full overflow-y-auto",
            "rounded-[var(--radius-md)] border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)] shadow-md py-1"
          ].join(" "),
          data: {"flat-pack--combobox-target": "list"}
        }
      end

      def render_option(option, index)
        selected = option[:value] == @value
        content_tag(:li,
          option[:label],
          id: "#{@list_id}-option-#{index}",
          role: "option",
          class: option_classes(selected),
          data: {
            "flat-pack--combobox-target": "option",
            value: option[:value],
            label: option[:label],
            action: "mousedown->flat-pack--combobox#choose"
          },
          aria: {selected: selected.to_s})
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--list-item-hover-background-color)]" "bg-[var(--list-item-active-background-color)]"
      def option_classes(selected)
        [
          "cursor-pointer px-3 py-2 text-sm",
          "text-[var(--surface-content-color)]",
          "aria-selected:bg-[var(--list-item-active-background-color)]",
          selected ? "bg-[var(--list-item-active-background-color)]" : "hover:bg-[var(--list-item-hover-background-color)]"
        ].join(" ")
      end

      def render_empty_row
        content_tag(:li,
          @empty_text,
          class: "hidden px-3 py-2 text-sm text-[var(--surface-muted-content-color)]",
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
        return if @options.any?

        raise ArgumentError, "options is required"
      end
    end
  end
end
