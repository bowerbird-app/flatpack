# frozen_string_literal: true

module FlatPack
  module TextArea
    class RichTextOptions
      ROOT_KEYS = %i[
        format
        bubble_menu
        floating_menu
        placeholder
        toolbar
        preset
        extensions
        mentions
        uploads
        tables
        collaboration
        character_count
        readonly
        autofocus
        output_input_type
        sanitization_profile
        ui
      ].freeze

      FORMAT_VALUES = %i[json html].freeze
      PRESET_VALUES = %i[minimal content full].freeze
      TOOLBAR_PRESET_VALUES = %i[minimal standard full].freeze
      OUTPUT_INPUT_TYPE_VALUES = %i[hidden_input hidden_textarea].freeze
      SANITIZATION_PROFILE_VALUES = %i[flatpack relaxed none].freeze
      UI_THEME_VALUES = %i[flatpack].freeze
      # `:adaptive` means "prefer TipTap menu/editor primitives, and bridge the
      # UI in FlatPack where upstream TipTap UI remains React/CLI-specific."
      UI_MODE_VALUES = %i[adaptive].freeze
      UI_DENSITY_VALUES = %i[comfortable compact].freeze

      TOOLBAR_ITEMS = %i[
        bold italic underline strike code highlight
        heading_2 heading_3 blockquote
        bullet_list ordered_list task_list
        link image table
        undo redo
        align_left align_center align_right
        color background_color
      ].freeze

      TOOLBAR_PRESETS = {
        minimal: %i[bold italic underline link bullet_list ordered_list undo redo],
        standard: %i[
          bold italic underline strike link
          heading_2 blockquote bullet_list ordered_list task_list
          undo redo align_left align_center align_right
        ],
        full: TOOLBAR_ITEMS
      }.freeze

      STARTER_KIT_KEYS = %i[
        bold italic strike code blockquote bullet_list ordered_list
        list_item paragraph text document hard_break heading
        horizontal_rule dropcursor gapcursor undo_redo
      ].freeze

      LIST_KIT_KEYS = %i[bullet_list ordered_list list_item task_list task_item].freeze
      TABLE_KIT_KEYS = %i[table table_row table_header table_cell].freeze
      TEXT_STYLE_KIT_KEYS = %i[text_style color background_color font_family font_size line_height].freeze

      # Presets intentionally build on one another (minimal -> content -> full)
      # so applications can opt into richer editing surfaces without enabling the
      # full registry for every editor instance.
      PRESET_EXTENSION_KEYS = {
        minimal: %i[
          starter_kit placeholder bubble_menu character_count link underline text_align
        ],
        content: %i[
          starter_kit placeholder bubble_menu character_count link underline text_align
          highlight text_style color background_color typography list_kit table_kit image
          code_block code_block_lowlight task_list task_item file_handler
        ],
        full: %i[
          starter_kit placeholder bubble_menu character_count link underline text_align
          highlight text_style color background_color typography list_kit table_kit image
          code_block code_block_lowlight task_list task_item file_handler
          font_family font_size line_height mention mathematics emoji audio youtube twitch
          details details_content details_summary table_of_contents collaboration
          collaboration_caret drag_handle invisible_characters unique_id floating_menu
          focus selection trailing_node gapcursor dropcursor list_keymap text_style_kit
        ]
      }.freeze

      SUPPORTED_EXTENSIONS = {
        bold: {category: :mark, managed_by: :starter_kit},
        code: {category: :mark, managed_by: :starter_kit},
        highlight: {category: :mark},
        italic: {category: :mark, managed_by: :starter_kit},
        link: {category: :mark},
        strike: {category: :mark, managed_by: :starter_kit},
        subscript: {category: :mark},
        superscript: {category: :mark},
        text_style: {category: :mark, managed_by: :text_style_kit},
        underline: {category: :mark},
        audio: {category: :node},
        blockquote: {category: :node, managed_by: :starter_kit},
        bullet_list: {category: :node, managed_by: :list_kit},
        code_block: {category: :node},
        code_block_lowlight: {category: :node},
        details: {category: :node},
        details_content: {category: :node},
        details_summary: {category: :node},
        document: {category: :node, managed_by: :starter_kit},
        emoji: {category: :node},
        hard_break: {category: :node, managed_by: :starter_kit},
        heading: {category: :node, managed_by: :starter_kit},
        horizontal_rule: {category: :node, managed_by: :starter_kit},
        image: {category: :node},
        list_item: {category: :node, managed_by: :list_kit},
        mathematics: {category: :node},
        mention: {category: :node},
        ordered_list: {category: :node, managed_by: :list_kit},
        paragraph: {category: :node, managed_by: :starter_kit},
        table: {category: :node, managed_by: :table_kit},
        table_cell: {category: :node, managed_by: :table_kit},
        table_header: {category: :node, managed_by: :table_kit},
        table_row: {category: :node, managed_by: :table_kit},
        task_item: {category: :node, managed_by: :list_kit},
        task_list: {category: :node, managed_by: :list_kit},
        text: {category: :node, managed_by: :starter_kit},
        twitch: {category: :node},
        youtube: {category: :node},
        background_color: {category: :functionality, managed_by: :text_style_kit},
        bubble_menu: {category: :functionality},
        character_count: {category: :functionality},
        collaboration: {category: :functionality},
        collaboration_caret: {category: :functionality},
        color: {category: :functionality, managed_by: :text_style_kit},
        drag_handle: {category: :functionality},
        dropcursor: {category: :functionality, managed_by: :starter_kit},
        file_handler: {category: :functionality},
        floating_menu: {category: :functionality},
        focus: {category: :functionality},
        font_family: {category: :functionality, managed_by: :text_style_kit},
        font_size: {category: :functionality, managed_by: :text_style_kit},
        gapcursor: {category: :functionality, managed_by: :starter_kit},
        invisible_characters: {category: :functionality},
        line_height: {category: :functionality, managed_by: :text_style_kit},
        list_kit: {category: :functionality},
        list_keymap: {category: :functionality},
        placeholder: {category: :functionality},
        selection: {category: :functionality},
        starter_kit: {category: :functionality},
        table_kit: {category: :functionality},
        table_of_contents: {category: :functionality},
        text_align: {category: :functionality},
        text_style_kit: {category: :functionality},
        trailing_node: {category: :functionality},
        typography: {category: :functionality},
        undo_redo: {category: :functionality, managed_by: :starter_kit},
        unique_id: {category: :functionality},
        drag_handle_react: {category: :wrapper, applicable: false},
        drag_handle_vue: {category: :wrapper, applicable: false}
      }.freeze

      TABLE_KEYS = %i[resizable last_column_resizable cell_min_width].freeze
      MENTIONS_KEYS = %i[trigger items items_url min_query_length suggestion_limit].freeze
      UPLOAD_KEYS = %i[endpoint method field_name accepted_types max_size].freeze
      COLLABORATION_KEYS = %i[provider_key document_key user_name user_color].freeze
      UI_KEYS = %i[theme mode density toolbar_label bubble_menu_label floating_menu_label].freeze

      class << self
        def normalize(raw_options, component_defaults: {})
          options = normalize_root_options(raw_options)

          preset = normalize_enum(:preset, options.fetch(:preset, :minimal), PRESET_VALUES)
          format = normalize_enum(:format, options.fetch(:format, :json), FORMAT_VALUES)
          bubble_menu = normalize_boolean(:bubble_menu, options.fetch(:bubble_menu, true))
          floating_menu = normalize_boolean(:floating_menu, options.fetch(:floating_menu, false))
          readonly = normalize_boolean(:readonly, options.fetch(:readonly, false))
          autofocus = normalize_boolean(:autofocus, options.fetch(:autofocus, false))
          character_count = normalize_boolean(
            :character_count,
            options.key?(:character_count) ? options[:character_count] : component_defaults.fetch(:character_count, false)
          )

          placeholder = options.key?(:placeholder) ? normalize_string(:placeholder, options[:placeholder], allow_blank: true) : component_defaults[:placeholder]
          toolbar = normalize_toolbar(options.fetch(:toolbar, :minimal))
          output_input_type = normalize_enum(:output_input_type, options.fetch(:output_input_type, :hidden_input), OUTPUT_INPUT_TYPE_VALUES)
          sanitization_profile = normalize_enum(
            :sanitization_profile,
            options.fetch(:sanitization_profile, :flatpack),
            SANITIZATION_PROFILE_VALUES
          )
          ui = normalize_ui(options[:ui], bubble_menu: bubble_menu, floating_menu: floating_menu)

          mentions = normalize_optional_settings(:mentions, options[:mentions], MENTIONS_KEYS) if options.key?(:mentions)
          uploads = normalize_optional_settings(:uploads, options[:uploads], UPLOAD_KEYS) if options.key?(:uploads)
          tables = normalize_optional_settings(:tables, options[:tables], TABLE_KEYS) if options.key?(:tables)
          collaboration = normalize_optional_settings(:collaboration, options[:collaboration], COLLABORATION_KEYS) if options.key?(:collaboration)

          extensions = build_extensions(
            preset: preset,
            extension_overrides: normalize_extensions(options.fetch(:extensions, {})),
            bubble_menu: bubble_menu,
            floating_menu: floating_menu,
            character_count: character_count,
            placeholder: placeholder,
            mentions: mentions,
            uploads: uploads,
            tables: tables,
            collaboration: collaboration
          )

          {
            format: format,
            preset: preset,
            bubble_menu: bubble_menu,
            floating_menu: floating_menu,
            placeholder: placeholder,
            toolbar: toolbar,
            extensions: extensions,
            mentions: mentions,
            uploads: uploads,
            tables: tables,
            collaboration: collaboration,
            character_count: character_count,
            readonly: readonly,
            autofocus: autofocus,
            output_input_type: output_input_type,
            sanitization_profile: sanitization_profile,
            ui: ui
          }.compact
        end

        def supported_extensions
          SUPPORTED_EXTENSIONS
        end

        private

        def normalize_root_options(raw_options)
          return {} if raw_options.nil?
          raise ArgumentError, "rich_text_options must be a Hash" unless raw_options.is_a?(Hash)

          options = deep_symbolize(raw_options)
          unknown_keys = options.keys - ROOT_KEYS
          raise ArgumentError, "Unknown rich_text_options: #{unknown_keys.join(', ')}" if unknown_keys.any?

          options
        end

        def normalize_toolbar(value)
          if value.is_a?(Symbol) || value.is_a?(String)
            preset = normalize_enum(:toolbar, value, TOOLBAR_PRESET_VALUES)
            return {
              preset: preset,
              items: TOOLBAR_PRESETS.fetch(preset)
            }
          end

          unless value.is_a?(Array)
            raise ArgumentError, "rich_text_options.toolbar must be :minimal, :standard, :full, or an Array of toolbar items"
          end

          items = value.map { |item| normalize_enum(:toolbar_item, item, TOOLBAR_ITEMS) }
          {
            preset: :custom,
            items: items
          }
        end

        def normalize_extensions(raw_extensions)
          raise ArgumentError, "rich_text_options.extensions must be a Hash" unless raw_extensions.is_a?(Hash)

          extensions = deep_symbolize(raw_extensions)
          unknown_keys = extensions.keys - SUPPORTED_EXTENSIONS.keys
          raise ArgumentError, "Unknown TipTap extensions: #{unknown_keys.join(', ')}" if unknown_keys.any?

          extensions.each_with_object({}) do |(key, value), normalized|
            metadata = SUPPORTED_EXTENSIONS.fetch(key)

            if metadata[:applicable] == false && truthy_extension_value?(value)
              raise ArgumentError, "#{key} is a framework-specific TipTap wrapper and is not supported by FlatPack's Stimulus integration"
            end

            normalized[key] = normalize_extension_value(key, value)
          end
        end

        def normalize_extension_value(key, value)
          case value
          when true, false, nil
            value
          when Hash
            deep_symbolize(value)
          else
            raise ArgumentError, "rich_text_options.extensions.#{key} must be a Boolean or Hash"
          end
        end

        def build_extensions(preset:, extension_overrides:, bubble_menu:, floating_menu:, character_count:, placeholder:, mentions:, uploads:, tables:, collaboration:)
          extensions = {}

          PRESET_EXTENSION_KEYS.fetch(preset).each do |key|
            extensions[key] = true
          end

          extensions[:bubble_menu] = bubble_menu
          extensions[:floating_menu] = floating_menu
          extensions[:character_count] = character_count
          extensions[:placeholder] = placeholder.present?

          if mentions == false
            extensions[:mention] = false
          elsif mentions.present?
            extensions[:mention] = mentions
          end

          if uploads == false
            extensions[:file_handler] = false
          elsif uploads.present?
            extensions[:file_handler] = uploads
          end

          if tables == false
            extensions[:table_kit] = false
          elsif tables.present?
            extensions[:table_kit] = tables
          end

          if collaboration == false
            extensions[:collaboration] = false
            extensions[:collaboration_caret] = false
          elsif collaboration.present?
            extensions[:collaboration] = collaboration
            extensions[:collaboration_caret] = collaboration
          end

          extensions.merge!(extension_overrides)

          expand_managed_extensions!(extensions)
          stringify_extension_hash(extensions)
        end

        def expand_managed_extensions!(extensions)
          apply_managed_keys!(extensions, :starter_kit, STARTER_KIT_KEYS)
          apply_managed_keys!(extensions, :list_kit, LIST_KIT_KEYS)
          apply_managed_keys!(extensions, :table_kit, TABLE_KIT_KEYS)
          apply_managed_keys!(extensions, :text_style_kit, TEXT_STYLE_KIT_KEYS)
        end

        def apply_managed_keys!(extensions, manager_key, managed_keys)
          return unless truthy_extension_value?(extensions[manager_key])

          managed_keys.each do |key|
            extensions[key] = true unless extensions.key?(key)
          end
        end

        def normalize_optional_settings(name, value, allowed_keys)
          return false if value == false || value.nil?

          unless value.is_a?(Hash)
            raise ArgumentError, "rich_text_options.#{name} must be false/nil or a Hash"
          end

          normalized = deep_symbolize(value)
          unknown_keys = normalized.keys - allowed_keys
          raise ArgumentError, "Unknown rich_text_options.#{name} keys: #{unknown_keys.join(', ')}" if unknown_keys.any?

          normalized
        end

        def normalize_ui(value, bubble_menu:, floating_menu:)
          raise ArgumentError, "rich_text_options.ui must be a Hash" unless value.nil? || value.is_a?(Hash)

          normalized = deep_symbolize(value || {})
          unknown_keys = normalized.keys - UI_KEYS
          raise ArgumentError, "Unknown rich_text_options.ui keys: #{unknown_keys.join(', ')}" if unknown_keys.any?

          {
            theme: normalize_enum(:ui_theme, normalized.fetch(:theme, :flatpack), UI_THEME_VALUES),
            mode: normalize_enum(:ui_mode, normalized.fetch(:mode, :adaptive), UI_MODE_VALUES),
            density: normalize_enum(:ui_density, normalized.fetch(:density, :comfortable), UI_DENSITY_VALUES),
            toolbar_label: normalize_string(:ui_toolbar_label, normalized.fetch(:toolbar_label, "TipTap UI toolbar"), allow_blank: false),
            bubble_menu_label: normalize_string(:ui_bubble_menu_label, normalized.fetch(:bubble_menu_label, "TipTap UI bubble menu"), allow_blank: false),
            floating_menu_label: normalize_string(:ui_floating_menu_label, normalized.fetch(:floating_menu_label, "TipTap UI floating menu"), allow_blank: false),
            bubble_menu: bubble_menu,
            floating_menu: floating_menu
          }
        end

        def normalize_enum(name, value, allowed_values)
          candidate = value.to_s.tr("-", "_").downcase.to_sym
          return candidate if allowed_values.include?(candidate)

          raise ArgumentError, "rich_text_options.#{name} must be one of: #{allowed_values.join(', ')}"
        end

        def normalize_boolean(name, value)
          return value if value == true || value == false

          raise ArgumentError, "rich_text_options.#{name} must be true or false"
        end

        def normalize_string(name, value, allow_blank: false)
          raise ArgumentError, "rich_text_options.#{name} must be a String" unless value.is_a?(String)
          raise ArgumentError, "rich_text_options.#{name} cannot be blank" if !allow_blank && value.strip.empty?

          value
        end

        def deep_symbolize(value)
          case value
          when Hash
            value.each_with_object({}) do |(key, nested_value), normalized|
              normalized[key.to_s.tr("-", "_").downcase.to_sym] = deep_symbolize(nested_value)
            end
          when Array
            value.map { |item| deep_symbolize(item) }
          else
            value
          end
        end

        def stringify_extension_hash(extensions)
          extensions.each_with_object({}) do |(key, value), normalized|
            normalized[key.to_s] = value
          end
        end

        def truthy_extension_value?(value)
          value == true || value.is_a?(Hash)
        end
      end
    end
  end
end
