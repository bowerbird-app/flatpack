# frozen_string_literal: true

module FlatPack
  module TextArea
    class RichTextOptions
      FORMATS = %i[json html].freeze
      TOOLBAR_PRESETS = %i[minimal standard full].freeze
      PRESETS = %i[minimal content full].freeze
      OUTPUT_INPUT_TYPES = %i[hidden_input hidden_textarea].freeze
      BOOLEAN_FEATURE_KEYS = %i[
        bubble_menu
        floating_menu
        character_count
        readonly
        autofocus
      ].freeze
      HASH_FEATURE_KEYS = %i[
        mentions
        uploads
        tables
        collaboration
        ui
      ].freeze
      TOOLBAR_LAYOUTS = {
        minimal: [
          %i[bold italic underline link],
          %i[bullet_list ordered_list],
          %i[undo redo]
        ],
        standard: [
          %i[bold italic underline strike code highlight link],
          %i[heading blockquote bullet_list ordered_list task_list],
          %i[align_left align_center align_right],
          %i[undo redo]
        ],
        full: [
          %i[bold italic underline strike code highlight color background_color link],
          %i[heading blockquote bullet_list ordered_list task_list table image],
          %i[align_left align_center align_right],
          %i[undo redo]
        ]
      }.freeze
      TOOLBAR_COMMANDS = TOOLBAR_LAYOUTS.values.flatten.flatten.uniq.freeze
      EXTENSION_CATALOG = {
        starter_kit: {package: "@tiptap/starter-kit", category: :functionality},
        bold: {package: "@tiptap/starter-kit", category: :mark},
        code: {package: "@tiptap/starter-kit", category: :mark},
        highlight: {package: "@tiptap/extension-highlight", category: :mark},
        italic: {package: "@tiptap/starter-kit", category: :mark},
        link: {package: "@tiptap/extension-link", category: :mark},
        strike: {package: "@tiptap/starter-kit", category: :mark},
        subscript: {package: "@tiptap/extension-subscript", category: :mark},
        superscript: {package: "@tiptap/extension-superscript", category: :mark},
        text_style: {package: "@tiptap/extension-text-style", category: :mark},
        underline: {package: "@tiptap/extension-underline", category: :mark},
        audio: {package: "@tiptap/extension-audio", category: :node},
        blockquote: {package: "@tiptap/starter-kit", category: :node},
        bullet_list: {package: "@tiptap/starter-kit", category: :node},
        code_block: {package: "@tiptap/starter-kit", category: :node},
        code_block_lowlight: {package: "@tiptap/extension-code-block-lowlight", category: :node},
        details: {package: "@tiptap/extension-details", category: :node},
        details_content: {package: "@tiptap/extension-details-content", category: :node},
        details_summary: {package: "@tiptap/extension-details-summary", category: :node},
        document: {package: "@tiptap/core", category: :node},
        emoji: {package: "@tiptap/extension-emoji", category: :node},
        hard_break: {package: "@tiptap/starter-kit", category: :node},
        heading: {package: "@tiptap/starter-kit", category: :node},
        horizontal_rule: {package: "@tiptap/starter-kit", category: :node},
        image: {package: "@tiptap/extension-image", category: :node},
        list_item: {package: "@tiptap/starter-kit", category: :node},
        mathematics: {package: "@tiptap/extension-mathematics", category: :node},
        mention: {package: "@tiptap/extension-mention", category: :node},
        ordered_list: {package: "@tiptap/starter-kit", category: :node},
        paragraph: {package: "@tiptap/starter-kit", category: :node},
        table: {package: "@tiptap/extension-table", category: :node},
        table_cell: {package: "@tiptap/extension-table-cell", category: :node},
        table_header: {package: "@tiptap/extension-table-header", category: :node},
        table_row: {package: "@tiptap/extension-table-row", category: :node},
        task_item: {package: "@tiptap/extension-task-item", category: :node},
        task_list: {package: "@tiptap/extension-task-list", category: :node},
        text: {package: "@tiptap/core", category: :node},
        twitch: {package: "@tiptap/extension-twitch", category: :node},
        youtube: {package: "@tiptap/extension-youtube", category: :node},
        background_color: {package: "@tiptap/extension-background-color", category: :functionality},
        bubble_menu: {package: "@tiptap/extension-bubble-menu", category: :functionality},
        character_count: {package: "@tiptap/extension-character-count", category: :functionality},
        collaboration: {package: "@tiptap/extension-collaboration", category: :functionality},
        collaboration_caret: {package: "@tiptap/extension-collaboration-caret", category: :functionality},
        color: {package: "@tiptap/extension-color", category: :functionality},
        drag_handle: {package: "@tiptap/extension-drag-handle", category: :functionality},
        dropcursor: {package: "@tiptap/extension-dropcursor", category: :functionality},
        file_handler: {package: "@tiptap/extension-file-handler", category: :functionality},
        floating_menu: {package: "@tiptap/extension-floating-menu", category: :functionality},
        focus: {package: "@tiptap/extension-focus", category: :functionality},
        font_family: {package: "@tiptap/extension-font-family", category: :functionality},
        font_size: {package: "@tiptap/extension-font-size", category: :functionality},
        gapcursor: {package: "@tiptap/extension-gapcursor", category: :functionality},
        invisible_characters: {package: "@tiptap/extension-invisible-characters", category: :functionality},
        line_height: {package: "@tiptap/extension-line-height", category: :functionality},
        list_kit: {package: "@tiptap/extension-list", category: :functionality},
        list_keymap: {package: "@tiptap/extension-list-keymap", category: :functionality},
        placeholder: {package: "@tiptap/extension-placeholder", category: :functionality},
        selection: {package: "@tiptap/extension-selection", category: :functionality},
        table_kit: {package: "@tiptap/extension-table", category: :functionality},
        table_of_contents: {package: "@tiptap/extension-table-of-contents", category: :functionality},
        text_align: {package: "@tiptap/extension-text-align", category: :functionality},
        text_style_kit: {package: "@tiptap/extension-text-style", category: :functionality},
        trailing_node: {package: "@tiptap/extension-trailing-node", category: :functionality},
        typography: {package: "@tiptap/extension-typography", category: :functionality},
        undo_redo: {package: "@tiptap/starter-kit", category: :functionality},
        unique_id: {package: "@tiptap/extension-unique-id", category: :functionality}
      }.freeze
      PRESET_EXTENSIONS = {
        minimal: {
          starter_kit: true,
          placeholder: true,
          bubble_menu: true,
          character_count: true,
          link: true,
          underline: true,
          text_align: true
        },
        content: {
          starter_kit: true,
          placeholder: true,
          bubble_menu: true,
          character_count: true,
          link: true,
          underline: true,
          text_align: true,
          highlight: true,
          text_style: true,
          color: true,
          background_color: true,
          typography: true,
          list_kit: true,
          list_keymap: true,
          table_kit: true,
          table: true,
          table_row: true,
          table_header: true,
          table_cell: true,
          image: true,
          code_block: true,
          code_block_lowlight: true
        },
        full: {
          starter_kit: true,
          placeholder: true,
          bubble_menu: true,
          character_count: true,
          link: true,
          underline: true,
          text_align: true,
          highlight: true,
          text_style: true,
          color: true,
          background_color: true,
          typography: true,
          list_kit: true,
          list_keymap: true,
          table_kit: true,
          table: true,
          table_row: true,
          table_header: true,
          table_cell: true,
          image: true,
          code_block: true,
          code_block_lowlight: true,
          font_family: true,
          font_size: true,
          line_height: true,
          mention: true,
          mathematics: true,
          emoji: true,
          audio: true,
          youtube: true,
          twitch: true,
          details: true,
          details_summary: true,
          details_content: true,
          table_of_contents: true,
          collaboration: true,
          collaboration_caret: true,
          drag_handle: true,
          invisible_characters: true,
          unique_id: true,
          floating_menu: true,
          trailing_node: true,
          focus: true,
          selection: true,
          gapcursor: true,
          dropcursor: true,
          file_handler: true
        }
      }.freeze
      FRAMEWORK_WRAPPERS = {
        drag_handle_react: {package: "@tiptap/extension-drag-handle-react", applicable: false},
        drag_handle_vue: {package: "@tiptap/extension-drag-handle-vue-3", applicable: false}
      }.freeze
      ALLOWED_KEYS = (
        %i[
          format
          bubble_menu
          floating_menu
          placeholder
          toolbar
          preset
          extensions
          sanitization_profile
          output_input_type
        ] + BOOLEAN_FEATURE_KEYS + HASH_FEATURE_KEYS
      ).freeze

      def initialize(options:, placeholder:, character_count:)
        @options = normalize_hash(options || {}, name: :rich_text_options)
        @placeholder = placeholder
        @character_count = character_count
      end

      def to_h
        unknown_keys = @options.keys - ALLOWED_KEYS
        if unknown_keys.any?
          raise ArgumentError, "Unknown rich_text_options: #{unknown_keys.sort.join(", ")}"
        end

        preset = normalize_enum(:preset, @options[:preset] || :minimal, PRESETS)
        format = normalize_enum(:format, @options[:format] || :json, FORMATS)
        toolbar = normalize_toolbar(@options[:toolbar] || default_toolbar_for(preset))
        extensions = normalize_extensions(preset: preset, overrides: @options[:extensions] || {})
        apply_structured_extension_overrides!(extensions)

        character_count = if @options.key?(:character_count)
          normalize_boolean(:character_count, @options[:character_count])
        else
          @character_count
        end

        if character_count
          extensions[:character_count] = true if extensions[:character_count].nil?
        else
          extensions[:character_count] = false
        end

        bubble_menu = normalize_boolean(:bubble_menu, @options.fetch(:bubble_menu, true))
        floating_menu = normalize_boolean(:floating_menu, @options.fetch(:floating_menu, preset == :full))
        extensions[:bubble_menu] = bubble_menu
        extensions[:floating_menu] = floating_menu

        {
          format: format,
          bubble_menu: bubble_menu,
          floating_menu: floating_menu,
          placeholder: normalize_optional_string(:placeholder, @options[:placeholder]) || @placeholder,
          toolbar: toolbar,
          preset: preset,
          extensions: extensions,
          mentions: normalize_optional_feature_hash(:mentions, @options[:mentions]),
          uploads: normalize_optional_feature_hash(:uploads, @options[:uploads]),
          tables: normalize_optional_feature_hash(:tables, @options[:tables]),
          collaboration: normalize_optional_feature_hash(:collaboration, @options[:collaboration]),
          character_count: character_count,
          readonly: normalize_boolean(:readonly, @options.fetch(:readonly, false)),
          autofocus: normalize_boolean(:autofocus, @options.fetch(:autofocus, false)),
          output_input_type: normalize_enum(:output_input_type, @options[:output_input_type] || :hidden_input, OUTPUT_INPUT_TYPES),
          sanitization_profile: normalize_optional_string(:sanitization_profile, @options[:sanitization_profile]),
          ui: normalize_optional_feature_hash(:ui, @options[:ui]) || {},
          supported_extensions: EXTENSION_CATALOG,
          framework_wrappers: FRAMEWORK_WRAPPERS
        }
      end

      private

      def default_toolbar_for(preset)
        case preset
        when :minimal then :minimal
        when :content then :standard
        else :full
        end
      end

      def normalize_extensions(preset:, overrides:)
        override_hash = normalize_hash(overrides, name: :extensions)
        unknown_extensions = override_hash.keys - EXTENSION_CATALOG.keys
        if unknown_extensions.any?
          raise ArgumentError, "Unknown rich text extensions: #{unknown_extensions.sort.join(", ")}"
        end

        PRESET_EXTENSIONS.fetch(preset).merge(override_hash.transform_values do |value|
          case value
          when true, false
            value
          when Hash
            normalize_hash(value, name: :extensions)
          else
            raise ArgumentError, "rich_text_options[:extensions] values must be booleans or hashes"
          end
        end)
      end

      def apply_structured_extension_overrides!(extensions)
        mentions = normalize_optional_feature_hash(:mentions, @options[:mentions])
        uploads = normalize_optional_feature_hash(:uploads, @options[:uploads])
        tables = normalize_optional_feature_hash(:tables, @options[:tables])
        collaboration = normalize_optional_feature_hash(:collaboration, @options[:collaboration])

        unless mentions.nil?
          extensions[:mention] = (mentions == false) ? false : (mentions.presence || true)
        end

        unless uploads.nil?
          enabled_uploads = (uploads == false) ? false : (uploads.presence || true)
          extensions[:file_handler] = enabled_uploads
          extensions[:image] = enabled_uploads unless enabled_uploads == false
        end

        unless tables.nil?
          enabled_tables = (tables == false) ? false : (tables.presence || true)
          extensions[:table_kit] = enabled_tables
          extensions[:table] = enabled_tables
          extensions[:table_row] = enabled_tables
          extensions[:table_header] = enabled_tables
          extensions[:table_cell] = enabled_tables
        end

        unless collaboration.nil?
          enabled_collaboration = (collaboration == false) ? false : (collaboration.presence || true)
          extensions[:collaboration] = enabled_collaboration
          extensions[:collaboration_caret] = enabled_collaboration
        end
      end

      def normalize_toolbar(value)
        case value
        when Symbol, String
          preset = normalize_enum(:toolbar, value, TOOLBAR_PRESETS)
          TOOLBAR_LAYOUTS.fetch(preset).map { |group| group.map(&:to_s) }
        when Array
          value.map do |group|
            entries = group.is_a?(Array) ? group : [group]
            entries.map do |item|
              command = item.to_s.underscore.to_sym
              unless TOOLBAR_COMMANDS.include?(command)
                raise ArgumentError, "Unknown rich text toolbar item: #{item.inspect}"
              end

              command.to_s
            end
          end
        else
          raise ArgumentError, "rich_text_options[:toolbar] must be :minimal, :standard, :full, or an array"
        end
      end

      def normalize_optional_feature_hash(name, value)
        return nil if value.nil?
        return false if value == false
        return {} if value == true

        normalize_hash(value, name: name)
      end

      def normalize_hash(value, name:)
        unless value.is_a?(Hash)
          raise ArgumentError, "#{name} must be a Hash"
        end

        value.each_with_object({}) do |(key, nested_value), result|
          normalized_key = key.to_s.underscore.to_sym
          result[normalized_key] = nested_value.is_a?(Hash) ? normalize_hash(nested_value, name: name) : nested_value
        end
      end

      def normalize_boolean(name, value)
        return value if value == true || value == false

        raise ArgumentError, "rich_text_options[:#{name}] must be true or false"
      end

      def normalize_optional_string(name, value)
        return nil if value.nil?

        unless value.is_a?(String) || value.is_a?(Symbol)
          raise ArgumentError, "rich_text_options[:#{name}] must be a String or Symbol"
        end

        value.to_s
      end

      def normalize_enum(name, value, allowed_values)
        normalized = value.to_s.underscore.to_sym
        return normalized if allowed_values.include?(normalized)

        raise ArgumentError, "rich_text_options[:#{name}] must be one of: #{allowed_values.join(", ")}"
      end
    end
  end
end
