# frozen_string_literal: true

module FlatPack
  module TextArea
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-warning" "border-warning" "hidden" "sr-only"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        rows: 3,
        autogrow: true,
        submit_on_enter: false,
        character_count: false,
        min_characters: nil,
        max_characters: nil,
        rich_text: false,
        rich_text_options: {},
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = value
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @rows = rows
        @autogrow = autogrow
        @submit_on_enter = submit_on_enter
        @character_count = character_count
        @min_characters = min_characters
        @max_characters = max_characters
        @rich_text = rich_text
        @rich_text_options = build_rich_text_options(rich_text_options)

        validate_name!
        validate_rows!
        validate_character_limits!
        validate_rich_text_value!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_label,
            render_field,
            render_character_count,
            render_error
          ].compact)
        end
      end

      private

      def build_rich_text_options(options)
        return unless @rich_text

        FlatPack::TextArea::RichTextOptions.new(
          options: options,
          placeholder: @placeholder,
          character_count: @character_count
        ).to_h
      end

      def render_label
        return unless @label

        if @rich_text
          content_tag(:label, @label, class: label_classes, id: label_id)
        else
          label_tag(textarea_id, @label, class: label_classes)
        end
      end

      def render_field
        @rich_text ? render_rich_text_editor : render_textarea
      end

      def render_textarea
        content_tag(:textarea, @value, **textarea_attributes)
      end

      def render_rich_text_editor
        safe_join([
          render_toolbar,
          render_bubble_menu,
          render_floating_menu,
          content_tag(:div, "", **editor_surface_attributes),
          render_hidden_submission_field
        ].compact)
      end

      def render_toolbar
        return unless toolbar_groups.any?

        content_tag(:div, class: rich_text_toolbar_classes, data: {flat_pack__tiptap_target: "toolbar"}, role: "toolbar", aria: {label: rich_text_toolbar_label}) do
          safe_join(toolbar_groups.map { |group| render_toolbar_group(group, bubble: false) })
        end
      end

      def render_bubble_menu
        return unless @rich_text_options[:bubble_menu]

        content_tag(:div, class: rich_text_menu_classes, data: {flat_pack__tiptap_target: "bubbleMenu"}, aria: {label: "Text selection menu"}) do
          render_toolbar_group(bubble_menu_commands, bubble: true)
        end
      end

      def render_floating_menu
        return unless @rich_text_options[:floating_menu]

        content_tag(:div, class: rich_text_menu_classes, data: {flat_pack__tiptap_target: "floatingMenu"}, aria: {label: "Insert content menu"}) do
          render_toolbar_group(floating_menu_commands, bubble: true)
        end
      end

      def render_toolbar_group(commands, bubble:)
        content_tag(:div, class: rich_text_toolbar_group_classes) do
          safe_join(commands.filter_map do |command|
            render_toolbar_button(command, bubble: bubble)
          end)
        end
      end

      def render_toolbar_button(command, bubble:)
        definition = toolbar_button_definition(command)
        return unless definition

        button_tag(
          definition[:label],
          type: :button,
          class: rich_text_button_classes,
          data: {
            action: "flat-pack--tiptap#runCommand",
            flat_pack__tiptap_command: definition[:command],
            flat_pack__tiptap_bubble_button: bubble
          },
          title: definition[:title],
          aria: {label: definition[:title]}
        )
      end

      def render_hidden_submission_field
        if @rich_text_options[:output_input_type] == :hidden_textarea
          content_tag(:textarea, rich_text_input_value, **hidden_textarea_attributes)
        else
          tag.input(**hidden_input_attributes)
        end
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def render_character_count
        return unless effective_character_count?

        content_tag(
          :p,
          character_count_text,
          id: character_count_id,
          class: character_count_classes,
          data: {@rich_text ? :flat_pack__tiptap_target : :flat_pack__text_area_target => "count"}
        )
      end

      def textarea_attributes
        attrs = {
          name: @name,
          id: textarea_id,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          rows: @rows,
          class: textarea_classes,
          data: {
            flat_pack__text_area_target: "textarea",
            action: textarea_actions
          }.compact
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def editor_surface_attributes
        attrs = {
          id: textarea_id,
          class: editor_surface_classes,
          data: {
            flat_pack__tiptap_target: "editor"
          },
          role: "textbox",
          tabindex: @disabled ? -1 : 0,
          aria: editor_aria_attributes
        }

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def hidden_input_attributes
        {
          type: :hidden,
          name: @name,
          id: submission_field_id,
          value: rich_text_input_value,
          disabled: @disabled,
          data: {flat_pack__tiptap_target: "input"}
        }
      end

      def hidden_textarea_attributes
        {
          name: @name,
          id: submission_field_id,
          disabled: @disabled,
          hidden: true,
          class: "hidden",
          data: {flat_pack__tiptap_target: "input"}
        }
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def wrapper_attributes
        if @rich_text
          {
            class: wrapper_classes,
            data: {
              controller: "flat-pack--tiptap",
              flat_pack__tiptap_config_value: rich_text_config_json,
              flat_pack__tiptap_submit_on_enter_value: @submit_on_enter
            }.compact
          }
        else
          {
            class: wrapper_classes,
            data: {
              controller: "flat-pack--text-area",
              flat_pack__text_area_autogrow_value: @autogrow,
              flat_pack__text_area_submit_on_enter_value: @submit_on_enter,
              flat_pack__text_area_min_characters_value: @min_characters,
              flat_pack__text_area_max_characters_value: @max_characters,
              flat_pack__text_area_character_count_enabled_value: @character_count
            }.compact
          }
        end
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--surface-content-color)] mb-1.5"
        )
      end

      def textarea_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "rounded-md",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-[var(--surface-muted-content-color)]",
          "focus:outline-none focus:ring-2 focus:ring-inset focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          "resize-none"
        ]

        base_classes << (@error ? "border-warning" : "border-[var(--surface-border-color)]")

        classes(*base_classes, @custom_class)
      end

      def editor_surface_classes
        base_classes = [
          "flat-pack-input",
          "flat-pack-tiptap-editor",
          "w-full",
          "rounded-md",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "text-sm",
          "transition-colors duration-base",
          "focus-within:outline-none focus-within:ring-2 focus-within:ring-inset focus-within:ring-ring focus-within:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << (@error ? "border-warning" : "border-[var(--surface-border-color)]")
        base_classes << "opacity-50 cursor-not-allowed" if @disabled
        base_classes << "cursor-default" if rich_text_readonly?

        classes(*base_classes, @custom_class)
      end

      def rich_text_toolbar_classes
        "flat-pack-tiptap-toolbar mb-2 flex flex-wrap items-center gap-2 rounded-md border border-[var(--surface-border-color)] bg-[var(--surface-muted-background-color)] p-2"
      end

      def rich_text_toolbar_group_classes
        "flat-pack-tiptap-toolbar-group flex items-center gap-1"
      end

      def rich_text_menu_classes
        "flat-pack-tiptap-menu items-center gap-1 rounded-md border border-[var(--surface-border-color)] bg-[var(--surface-background-color)] p-1 shadow-lg"
      end

      def rich_text_button_classes
        "flat-pack-tiptap-button inline-flex min-h-9 min-w-9 items-center justify-center rounded-md border border-transparent px-2 py-1 text-xs font-medium text-[var(--surface-content-color)] transition-colors duration-base hover:bg-[var(--surface-muted-background-color)] focus:outline-none focus:ring-2 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
      end

      def error_classes
        "mt-1 text-sm text-warning"
      end

      def character_count_classes
        "mt-1 text-xs text-[var(--surface-muted-content-color)]"
      end

      def textarea_id
        @textarea_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def submission_field_id
        @submission_field_id ||= "#{textarea_id}_input"
      end

      def label_id
        @label_id ||= "#{textarea_id}_label"
      end

      def error_id
        "#{textarea_id}_error"
      end

      def character_count_id
        "#{textarea_id}_character_count"
      end

      def character_count_text
        count = initial_character_count

        if @max_characters
          "#{count}/#{@max_characters} characters"
        else
          "#{count} characters"
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def textarea_actions
        actions = ["input->flat-pack--text-area#updateCharacterCount"]
        actions.unshift("input->flat-pack--text-area#autoExpand") if @autogrow
        actions << "keydown->flat-pack--text-area#handleKeydown" if @submit_on_enter
        actions.join(" ")
      end

      def validate_rows!
        raise ArgumentError, "rows must be a positive integer" if @rows.to_i <= 0
      end

      def validate_character_limits!
        return unless effective_character_count?

        if @min_characters&.to_i&.negative?
          raise ArgumentError, "min_characters must be 0 or greater"
        end

        if @max_characters&.to_i&.negative?
          raise ArgumentError, "max_characters must be 0 or greater"
        end

        if @min_characters && @max_characters && @min_characters.to_i > @max_characters.to_i
          raise ArgumentError, "min_characters must be less than or equal to max_characters"
        end
      end

      def validate_rich_text_value!
        return unless @rich_text

        return if @value.nil? || @value == ""

        if rich_text_format == :json
          JSON.parse(rich_text_input_value)
        elsif !@value.is_a?(String)
          raise ArgumentError, "Rich text HTML content must be provided as a String"
        end
      rescue JSON::ParserError => error
        raise ArgumentError, "Rich text JSON value must be valid JSON: #{error.message}"
      end

      def effective_character_count?
        @rich_text ? @rich_text_options[:character_count] : @character_count
      end

      def rich_text_format
        @rich_text_options[:format]
      end

      def rich_text_readonly?
        @rich_text_options[:readonly]
      end

      def rich_text_toolbar_label
        @label.present? ? "#{@label} formatting toolbar" : "Rich text formatting toolbar"
      end

      def rich_text_config_json
        @rich_text_config_json ||= @rich_text_options.merge(
          disabled: @disabled,
          required: @required,
          min_characters: @min_characters,
          max_characters: @max_characters,
          input_id: submission_field_id,
          editor_id: textarea_id,
          error_id: error_id,
          character_count_id: character_count_id,
          label_id: @label ? label_id : nil
        ).to_json
      end

      def rich_text_input_value
        @rich_text_input_value ||=
          if rich_text_format == :json
            serialize_json_content(@value)
          else
            @value.to_s
          end
      end

      def serialize_json_content(value)
        case value
        when nil, ""
          JSON.generate(default_rich_text_document)
        when String
          JSON.parse(value)
          value
        when Hash
          JSON.generate(value.deep_stringify_keys)
        else
          if value.respond_to?(:to_h)
            JSON.generate(value.to_h.deep_stringify_keys)
          else
            raise ArgumentError, "Rich text JSON content must be a String or Hash"
          end
        end
      end

      def default_rich_text_document
        {
          type: "doc",
          content: [
            {
              type: "paragraph",
              content: []
            }
          ]
        }
      end

      def initial_character_count
        return (@value || "").to_s.length unless @rich_text

        if rich_text_format == :html
          helpers.strip_tags(@value.to_s).length
        else
          count_json_text(JSON.parse(rich_text_input_value))
        end
      rescue JSON::ParserError
        0
      end

      def count_json_text(node)
        case node
        when Hash
          text_length = node["text"].to_s.length
          text_length + Array(node["content"]).sum { |child| count_json_text(child) }
        when Array
          node.sum { |child| count_json_text(child) }
        else
          0
        end
      end

      def toolbar_groups
        @toolbar_groups ||= @rich_text_options[:toolbar].map do |group|
          group.select { |command| toolbar_command_enabled?(command) }
        end.reject(&:empty?)
      end

      def bubble_menu_commands
        %w[bold italic underline link].select { |command| toolbar_command_enabled?(command) }
      end

      def floating_menu_commands
        %w[heading bullet_list ordered_list task_list blockquote table].select { |command| toolbar_command_enabled?(command) }
      end

      def toolbar_command_enabled?(command)
        command_key = command.to_s
        extension_map = {
          "underline" => :underline,
          "highlight" => :highlight,
          "link" => :link,
          "task_list" => :task_list,
          "image" => :image,
          "table" => :table,
          "color" => :color,
          "background_color" => :background_color,
          "align_left" => :text_align,
          "align_center" => :text_align,
          "align_right" => :text_align
        }

        required_extension = extension_map[command_key]
        return true unless required_extension

        @rich_text_options[:extensions][required_extension] != false
      end

      def toolbar_button_definition(command)
        {
          "bold" => {label: "B", title: "Bold", command: "bold"},
          "italic" => {label: "I", title: "Italic", command: "italic"},
          "underline" => {label: "U", title: "Underline", command: "underline"},
          "strike" => {label: "S", title: "Strike", command: "strike"},
          "code" => {label: "{}", title: "Inline code", command: "code"},
          "highlight" => {label: "HL", title: "Highlight", command: "highlight"},
          "heading" => {label: "H", title: "Heading", command: "heading"},
          "blockquote" => {label: "❝", title: "Blockquote", command: "blockquote"},
          "bullet_list" => {label: "•", title: "Bullet list", command: "bullet_list"},
          "ordered_list" => {label: "1.", title: "Ordered list", command: "ordered_list"},
          "task_list" => {label: "☑", title: "Task list", command: "task_list"},
          "link" => {label: "🔗", title: "Link", command: "link"},
          "image" => {label: "🖼", title: "Image", command: "image"},
          "table" => {label: "▦", title: "Table", command: "table"},
          "undo" => {label: "↶", title: "Undo", command: "undo"},
          "redo" => {label: "↷", title: "Redo", command: "redo"},
          "align_left" => {label: "≡", title: "Align left", command: "align_left"},
          "align_center" => {label: "≣", title: "Align center", command: "align_center"},
          "align_right" => {label: "≢", title: "Align right", command: "align_right"},
          "color" => {label: "A", title: "Text color", command: "color"},
          "background_color" => {label: "▣", title: "Background color", command: "background_color"}
        }.fetch(command.to_s, nil)
      end

      def editor_aria_attributes
        described_by = [@error ? error_id : nil, effective_character_count? ? character_count_id : nil].compact.join(" ")

        {
          labelledby: @label ? label_id : nil,
          describedby: described_by.presence,
          invalid: @error ? "true" : nil,
          required: @required ? "true" : nil,
          readonly: rich_text_readonly? ? "true" : nil,
          disabled: @disabled ? "true" : nil,
          multiline: "true"
        }.compact
      end
    end
  end
end
