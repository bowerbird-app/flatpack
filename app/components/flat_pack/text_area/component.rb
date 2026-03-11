# frozen_string_literal: true

module FlatPack
  module TextArea
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-warning" "border-warning"

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
        @rich_text_options = @rich_text ? RichTextOptions.normalize(
          rich_text_options,
          component_defaults: {
            placeholder: @placeholder,
            character_count: @character_count
          }
        ) : nil

        validate_name!
        validate_rows!
        validate_character_limits!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_label,
            @rich_text ? render_rich_text_editor : render_textarea,
            render_character_count,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        return label_tag(textarea_id, @label, class: label_classes) unless @rich_text

        rich_text_label
      end

      def render_textarea
        content_tag(:textarea, @value, **textarea_attributes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id, data: rich_text_error_target)
      end

      def render_character_count
        return unless character_count_enabled?

        content_tag(
          :p,
          character_count_text,
          id: character_count_id,
          class: character_count_classes,
          data: @rich_text ? {flat_pack__tiptap_target: "count"} : {flat_pack__text_area_target: "count"}
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

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def wrapper_attributes
        return rich_text_wrapper_attributes if @rich_text

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

        base_classes << if @error
          "border-warning"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
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

      def error_id
        "#{textarea_id}_error"
      end

      def character_count_id
        "#{textarea_id}_character_count"
      end

      def character_count_text
        count = @rich_text ? rich_text_plain_text_length : (@value || "").to_s.length

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
        return unless character_count_enabled?

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

      def rich_text_label
        content_tag(
          :label,
          @label,
          class: label_classes,
          id: label_id,
          for: textarea_id,
          data: {action: "click->flat-pack--tiptap#focus"}
        )
      end

      def render_rich_text_editor
        content_tag(:div, class: rich_text_ui_root_classes, data: {flat_pack__tiptap_target: "uiRoot", flat_pack__tiptap_ui_role: "root"}) do
          safe_join([
            render_rich_text_toolbar,
            render_editor_surface,
            render_hidden_submission_field,
            render_bubble_menu,
            render_floating_menu
          ].compact)
        end
      end

      def render_rich_text_toolbar
        toolbar = @rich_text_options[:toolbar]
        return unless toolbar.present? && toolbar[:items].present?

        content_tag(
          :div,
          safe_join(toolbar[:items].map { |item| render_toolbar_button(item) }),
          class: rich_text_toolbar_classes,
          role: "toolbar",
          aria: {label: @rich_text_options.dig(:ui, :toolbar_label)},
          data: {
            flat_pack__tiptap_target: "toolbar",
            flat_pack__tiptap_ui_role: "toolbar"
          }
        )
      end

      def render_toolbar_button(item)
        definition = toolbar_button_definition(item)

        content_tag(
          :button,
          definition.fetch(:content),
          type: "button",
          class: toolbar_button_classes,
          aria: {label: definition.fetch(:label), pressed: "false"},
          data: {
            action: "click->flat-pack--tiptap#runToolbarAction",
            flat_pack__tiptap_command: definition.fetch(:command),
            flat_pack__tiptap_ui_component: "button"
          }.tap do |data|
            data[:flat_pack__tiptap_value] = definition[:value] if definition[:value]
          end
        )
      end

      def render_editor_surface
        content_tag(:div, nil, **editor_surface_attributes)
      end

      def render_hidden_submission_field
        if rich_text_output_input_type == :hidden_textarea
          content_tag(:textarea, serialized_rich_text_value, **hidden_textarea_attributes)
        else
          tag.input(**hidden_input_attributes)
        end
      end

      def render_bubble_menu
        return unless @rich_text_options[:bubble_menu]

        content_tag(
          :div,
          safe_join(%i[bold italic underline link].map { |item| render_toolbar_button(item) }),
          class: rich_text_menu_classes,
          role: "toolbar",
          aria: {label: @rich_text_options.dig(:ui, :bubble_menu_label)},
          data: {
            flat_pack__tiptap_target: "bubbleMenu",
            flat_pack__tiptap_ui_role: "bubble-menu"
          }
        )
      end

      def render_floating_menu
        return unless @rich_text_options[:floating_menu]

        content_tag(
          :div,
          safe_join(%i[heading_2 bullet_list ordered_list blockquote].map { |item| render_toolbar_button(item) }),
          class: rich_text_menu_classes,
          role: "toolbar",
          aria: {label: @rich_text_options.dig(:ui, :floating_menu_label)},
          data: {
            flat_pack__tiptap_target: "floatingMenu",
            flat_pack__tiptap_ui_role: "floating-menu"
          }
        )
      end

      def rich_text_wrapper_attributes
        {
          class: wrapper_classes,
          data: {
            controller: "flat-pack--tiptap",
            flat_pack__tiptap_config_value: rich_text_controller_config.to_json,
            flat_pack__tiptap_min_characters_value: @min_characters,
            flat_pack__tiptap_max_characters_value: @max_characters
          }.compact
        }
      end

      def rich_text_controller_config
        @rich_text_options.merge(
          required: @required,
          disabled: @disabled,
          error_id: error_id
        )
      end

      def editor_surface_attributes
        {
          id: textarea_id,
          role: "textbox",
          tabindex: @disabled ? "-1" : "0",
          contenteditable: (!readonly?).to_s,
          class: editor_surface_classes,
          data: editor_surface_data_attributes,
          aria: editor_surface_aria_attributes
        }.merge(html_attributes.except(:id))
      end

      def hidden_input_attributes
        {
          type: "hidden",
          name: @name,
          id: hidden_input_id,
          value: serialized_rich_text_value,
          disabled: @disabled,
          data: {flat_pack__tiptap_target: "input"}
        }.merge(hidden_input_html_attributes)
      end

      def hidden_textarea_attributes
        {
          name: @name,
          id: hidden_input_id,
          class: "hidden",
          hidden: true,
          disabled: @disabled,
          data: {flat_pack__tiptap_target: "input"}
        }.merge(hidden_input_html_attributes)
      end

      def editor_surface_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "min-h-[8rem]",
          "rounded-md",
          "border",
          "bg-[var(--surface-background-color)]",
          "text-[var(--surface-content-color)]",
          "px-[var(--form-control-padding)]",
          "py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors",
          "focus:outline-none",
          "focus:ring-2",
          "focus:ring-inset",
          "focus:ring-ring",
          "focus:border-transparent",
          "disabled:cursor-not-allowed",
          "disabled:opacity-50"
        ]

        base_classes << if @error
          "border-warning"
        else
          "border-[var(--surface-border-color)]"
        end

        base_classes << "opacity-60 cursor-not-allowed" if @disabled
        base_classes << "bg-[var(--surface-muted-background-color)]" if readonly?

        classes(*base_classes, @custom_class)
      end

      def editor_surface_data_attributes
        data_attributes.merge(flat_pack__tiptap_target: "editor")
      end

      def editor_surface_aria_attributes
        merge_aria_attributes(
          aria_attributes,
          error_id: error_id,
          has_error: @error.present?
        ).merge(
          multiline: "true",
          labelledby: (@label ? label_id : nil),
          readonly: readonly?.to_s,
          disabled: @disabled.to_s,
          required: @required.to_s
        ).compact
      end

      def hidden_input_html_attributes
        html_attributes.except(:id, :class).merge(form: html_attributes[:form])
      end

      def rich_text_output_input_type
        @rich_text_options[:output_input_type]
      end

      def hidden_input_id
        "#{textarea_id}_input"
      end

      def label_id
        "#{textarea_id}_label"
      end

      def character_count_enabled?
        @rich_text ? @rich_text_options[:character_count] : @character_count
      end

      def readonly?
        @disabled || @rich_text_options[:readonly]
      end

      def rich_text_error_target
        @rich_text ? {flat_pack__tiptap_target: "error"} : {}
      end

      def serialized_rich_text_value
        @serialized_rich_text_value ||= begin
          if @rich_text_options[:format] == :html
            sanitize_initial_html(@value.to_s)
          else
            serialize_json_rich_text_value
          end
        end
      end

      def serialize_json_rich_text_value
        case @value
        when nil
          JSON.generate(empty_document)
        when Hash, Array
          JSON.generate(@value)
        when String
          stripped_value = @value.strip
          return JSON.generate(empty_document) if stripped_value.empty?

          # Parse once here so invalid JSON raises early, but keep the original
          # string for deterministic hidden-field submission and JS bootstrapping.
          JSON.parse(stripped_value)
          stripped_value
        else
          JSON.generate(document_from_plain_text(@value.to_s))
        end
      rescue JSON::ParserError
        JSON.generate(document_from_plain_text(@value.to_s))
      end

      def sanitize_initial_html(html)
        return html if @rich_text_options[:sanitization_profile] == :none

        helpers.sanitize(
          html,
          tags: rich_text_allowed_tags,
          attributes: rich_text_allowed_attributes
        )
      end

      def rich_text_allowed_tags
        relaxed_tags = %w[
          a audio blockquote br code details div em h1 h2 h3 h4 h5 h6 hr iframe img li
          mark math ol p pre span strong sub summary sup table tbody td th thead tr u ul
        ]

        return relaxed_tags if @rich_text_options[:sanitization_profile] == :relaxed

        %w[a blockquote br code em h2 h3 hr li mark ol p pre span strong sub sup table tbody td th thead tr u ul]
      end

      def rich_text_allowed_attributes
        relaxed_attributes = %w[
          alt class colspan controls href open rel rowspan src start style target title
        ]

        return relaxed_attributes if @rich_text_options[:sanitization_profile] == :relaxed

        %w[alt colspan href rel rowspan src start target title]
      end

      def empty_document
        {
          type: "doc",
          content: [
            {type: "paragraph"}
          ]
        }
      end

      def document_from_plain_text(text)
        return empty_document if text.blank?

        {
          type: "doc",
          content: [
            {
              type: "paragraph",
              content: [
                {
                  type: "text",
                  text: text
                }
              ]
            }
          ]
        }
      end

      def rich_text_plain_text_length
        if @rich_text_options[:format] == :html
          helpers.strip_tags(serialized_rich_text_value).to_s.length
        else
          json_document_text(serialized_rich_text_value).length
        end
      end

      def json_document_text(value)
        parsed_value = JSON.parse(value)
        extract_text_nodes(parsed_value).join
      rescue JSON::ParserError
        # Fall back to the raw string so character-count rendering stays resilient
        # even if malformed persisted JSON reaches the component.
        value.to_s
      end

      def extract_text_nodes(node)
        case node
        when Hash
          texts = []
          texts << node["text"].to_s if node["text"]
          Array(node["content"]).each { |child| texts.concat(extract_text_nodes(child)) }
          texts
        when Array
          node.flat_map { |child| extract_text_nodes(child) }
        else
          []
        end
      end

      def toolbar_button_definition(item)
        definitions = {
          bold: {label: "Bold", content: "B", command: "bold"},
          italic: {label: "Italic", content: "I", command: "italic"},
          underline: {label: "Underline", content: "U", command: "underline"},
          strike: {label: "Strikethrough", content: "S", command: "strike"},
          code: {label: "Code", content: "</>", command: "code"},
          highlight: {label: "Highlight", content: "HL", command: "highlight"},
          heading_2: {label: "Heading 2", content: "H2", command: "heading", value: "2"},
          heading_3: {label: "Heading 3", content: "H3", command: "heading", value: "3"},
          blockquote: {label: "Blockquote", content: "❝", command: "blockquote"},
          bullet_list: {label: "Bullet list", content: "• List", command: "bulletList"},
          ordered_list: {label: "Ordered list", content: "1. List", command: "orderedList"},
          task_list: {label: "Task list", content: "☑", command: "taskList"},
          link: {label: "Link", content: "Link", command: "link"},
          image: {label: "Image", content: "Image", command: "image"},
          table: {label: "Insert table", content: "Table", command: "table"},
          undo: {label: "Undo", content: "Undo", command: "undo"},
          redo: {label: "Redo", content: "Redo", command: "redo"},
          align_left: {label: "Align left", content: "⇤", command: "textAlign", value: "left"},
          align_center: {label: "Align center", content: "≡", command: "textAlign", value: "center"},
          align_right: {label: "Align right", content: "⇥", command: "textAlign", value: "right"},
          color: {label: "Text color", content: "Text", command: "color"},
          background_color: {label: "Background color", content: "Bg", command: "backgroundColor"}
        }

        definitions.fetch(item)
      end

      def toolbar_button_classes
        "inline-flex items-center justify-center rounded-md border border-[var(--surface-border-color)] bg-[var(--surface-background-color)] px-2.5 py-1.5 text-xs font-medium text-[var(--surface-content-color)] transition hover:bg-[var(--surface-muted-background-color)] focus:outline-none focus:ring-2 focus:ring-ring"
      end

      def rich_text_ui_root_classes
        density_class = @rich_text_options.dig(:ui, :density) == :compact ? "space-y-2" : "space-y-3"
        classes("flat-pack-tiptap-ui", density_class)
      end

      def rich_text_toolbar_classes
        density_padding = @rich_text_options.dig(:ui, :density) == :compact ? "p-1.5" : "p-2"
        classes(
          "flat-pack-tiptap-ui-toolbar mb-2 flex flex-wrap items-center gap-2 rounded-md border border-[var(--surface-border-color)] bg-[var(--surface-panel-background-color)]",
          density_padding
        )
      end

      def rich_text_menu_classes
        density_padding = @rich_text_options.dig(:ui, :density) == :compact ? "p-1.5" : "p-2"
        classes(
          "flat-pack-tiptap-ui-menu hidden items-center gap-1 rounded-md border border-[var(--surface-border-color)] bg-[var(--surface-panel-background-color)] shadow-lg",
          density_padding
        )
      end
    end
  end
end
