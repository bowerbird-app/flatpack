# frozen_string_literal: true

module FlatPack
  module TextArea
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"

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
        quick_copy: false,
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
        @quick_copy = quick_copy
        @min_characters = min_characters
        @max_characters = max_characters
        @rich_text = rich_text

        # Build and validate rich text options early so consumers get clear feedback.
        @rich_text_options = @rich_text ? RichTextOptions.new(rich_text_options) : nil

        validate_name!
        validate_rows! unless @rich_text
        validate_character_limits! unless @rich_text
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          if @rich_text
            safe_join([
              render_label,
              render_rich_text_editor_surface,
              render_rich_text_character_count,
              render_error
            ].compact)
          else
            safe_join([
              render_label,
              render_textarea,
              render_character_count,
              render_error
            ].compact)
          end
        end
      end

      private

      # ── Shared helpers used in both modes ────────────────────────────────────

      def render_label
        return unless @label

        label_tag(field_id, @label, class: label_classes)
      end

      def render_textarea
        return content_tag(:textarea, @value, **textarea_attributes) unless @quick_copy

        content_tag(:div, class: quick_copy_wrapper_classes) do
          safe_join([
            content_tag(:textarea, @value, **textarea_attributes),
            render_copy_button
          ])
        end
      end

      def textarea_attributes
        attrs = {
          name: @name,
          id: field_id,
          placeholder: @placeholder,
          disabled: @disabled,
          readonly: @quick_copy,
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

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def render_copy_button
        content_tag(
          :button,
          type: "button",
          class: copy_button_classes,
          disabled: @disabled,
          data: {
            action: "click->flat-pack--text-area#copyFromButton",
            flat_pack__text_area_target: "copyButton"
          },
          aria: {label: "Copy textarea value"}
        ) do
          render FlatPack::Shared::IconComponent.new(name: "clipboard-document", size: :sm)
        end
      end

      # ── Plain textarea mode ──────────────────────────────────────────────────

      def render_character_count
        return unless @character_count

        content_tag(
          :p,
          character_count_text,
          id: character_count_id,
          class: character_count_classes,
          data: {flat_pack__text_area_target: "count"}
        )
      end

      # ── Rich text editor mode ────────────────────────────────────────────────

      # Renders the full rich-text editor scaffold: toolbar, editor surface,
      # bubble/floating menu containers, and the hidden submission field.
      # All containers are populated by the TipTap Stimulus controller
      # (flat-pack--tiptap) after TipTap is initialized client-side.
      def render_rich_text_editor_surface
        safe_join([
          render_rich_text_toolbar_region,
          render_rich_text_editor_container,
          render_bubble_menu_region,
          render_floating_menu_region,
          render_rich_text_hidden_field
        ].compact)
      end

      # Empty toolbar container — JavaScript populates buttons based on preset.
      def render_rich_text_toolbar_region
        return if @rich_text_options.options[:toolbar] == :none

        content_tag(
          :div,
          "",
          class: "flat-pack-richtext-toolbar",
          role: "toolbar",
          data: {flat_pack__tiptap_target: "toolbar"},
          aria: {label: "Formatting toolbar"}
        )
      end

      # The container where TipTap mounts the ProseMirror contenteditable surface.
      def render_rich_text_editor_container
        content_tag(
          :div,
          "",
          class: rich_text_editor_container_classes,
          data: {flat_pack__tiptap_target: "editorContainer"}
        )
      end

      # Shown by TipTap's BubbleMenu extension when text is selected.
      def render_bubble_menu_region
        return unless @rich_text_options.options[:bubble_menu]

        content_tag(
          :div,
          "",
          class: "flat-pack-richtext-bubble-menu",
          data: {flat_pack__tiptap_target: "bubbleMenu"}
        )
      end

      # Shown by TipTap's FloatingMenu extension at empty paragraphs.
      def render_floating_menu_region
        return unless @rich_text_options.options[:floating_menu]

        content_tag(
          :div,
          "",
          class: "flat-pack-richtext-floating-menu",
          data: {flat_pack__tiptap_target: "floatingMenu"}
        )
      end

      # Character count display updated by TipTap's CharacterCount extension.
      # Enabled when character_count is set via component prop OR rich_text_options.
      def render_rich_text_character_count
        return unless @character_count || @rich_text_options.options[:character_count]

        content_tag(
          :p,
          "0 characters",
          id: character_count_id,
          class: character_count_classes,
          data: {flat_pack__tiptap_target: "characterCount"}
        )
      end

      # Hidden input synchronized by the TipTap controller; the actual form field.
      def render_rich_text_hidden_field
        attrs = {
          type: "hidden",
          name: @name,
          id: "#{field_id}_hidden",
          value: (@value || "").to_s,
          data: {flat_pack__tiptap_target: "hiddenField"}
        }
        attrs[:disabled] = true if @disabled
        tag.input(**attrs)
      end

      # ── Wrapper attributes dispatched by mode ────────────────────────────────

      def wrapper_attributes
        @rich_text ? rich_text_wrapper_attributes : plain_textarea_wrapper_attributes
      end

      def plain_textarea_wrapper_attributes
        {
          class: wrapper_classes,
          data: {
            controller: "flat-pack--text-area",
            flat_pack__text_area_autogrow_value: @autogrow,
            flat_pack__text_area_submit_on_enter_value: @submit_on_enter,
            flat_pack__text_area_min_characters_value: @min_characters,
            flat_pack__text_area_max_characters_value: @max_characters,
            flat_pack__text_area_character_count_enabled_value: @character_count,
            flat_pack__text_area_quick_copy_enabled_value: @quick_copy
          }.compact
        }
      end

      def rich_text_wrapper_attributes
        opts_json = @rich_text_options.for_json.to_json

        data_attrs = {
          controller: "flat-pack--tiptap",
          flat_pack__tiptap_options_value: opts_json,
          flat_pack__tiptap_editor_id_value: field_id,
          flat_pack__tiptap_placeholder_value: @placeholder,
          flat_pack__tiptap_disabled_value: @disabled,
          flat_pack__tiptap_required_value: @required,
          flat_pack__tiptap_has_error_value: @error.present?,
          flat_pack__tiptap_error_id_value: @error.present? ? error_id : nil,
          flat_pack__tiptap_value_value: (@value || "").to_s
        }.compact

        {class: rich_text_wrapper_classes, data: data_attrs}
      end

      # ── CSS class helpers ────────────────────────────────────────────────────

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def rich_text_wrapper_classes
        base = ["flat-pack-input-wrapper", "flat-pack-richtext-wrapper"]
        base << "flat-pack-richtext--error" if @error.present?
        base << "flat-pack-richtext--disabled" if @disabled
        base << "flat-pack-richtext--required" if @required
        classes(*base, @custom_class)
      end

      def rich_text_editor_container_classes
        [
          "flat-pack-richtext-editor",
          @error ? "border-[var(--color-warning)]" : "border-[var(--surface-border-color)]"
        ].join(" ")
      end

      def label_classes
        classes("block text-sm font-medium text-[var(--surface-content-color)] mb-1.5")
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

        base_classes << "pr-10" if @quick_copy

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-warning)]"
      end

      def character_count_classes
        "mt-1 text-xs text-[var(--surface-muted-content-color)]"
      end

      def quick_copy_wrapper_classes
        "relative"
      end

      def copy_button_classes
        classes(
          "absolute right-2 top-2",
          "inline-flex items-center justify-center",
          "h-6 w-6 rounded",
          "text-[var(--surface-muted-content-color)]",
          "hover:text-[var(--surface-content-color)]",
          "hover:bg-[var(--surface-muted-background-color)]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        )
      end

      # ── ID helpers ───────────────────────────────────────────────────────────

      # Unified field ID for the label `for` attribute in both modes.
      # In rich text mode, this ID is passed to JS which sets it as the
      # editorProps id on the ProseMirror element for label-to-editor association.
      def field_id
        @field_id ||= @system_arguments[:id] ||
          "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      # Backward-compatible alias so plain-textarea internal methods still work.
      alias_method :textarea_id, :field_id

      def error_id
        "#{field_id}_error"
      end

      def character_count_id
        "#{field_id}_character_count"
      end

      def character_count_text
        count = (@value || "").to_s.length

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
        actions << "click->flat-pack--text-area#copyFromTextarea" if @quick_copy
        actions.join(" ")
      end

      def validate_rows!
        raise ArgumentError, "rows must be a positive integer" if @rows.to_i <= 0
      end

      def validate_character_limits!
        return unless @character_count

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
    end
  end
end
