# frozen_string_literal: true

module FlatPack
  module TextArea
    # Validates, normalizes, and serializes options for TipTap rich text mode.
    #
    # All keys are accepted as either Symbol or String and are normalized to Symbol internally.
    # Call `for_json` to get a deep-serialized Hash safe for JSON data-attribute embedding.
    #
    # == Supported options
    #
    #   format:          :json | :html                 (default: :json)
    #   preset:          :minimal | :content | :full   (default: :minimal)
    #   toolbar:         :minimal | :standard | :full | :none | Array<String>  (default: :standard)
    #   bubble_menu:     Boolean                        (default: true)
    #   floating_menu:   Boolean                        (default: false)
    #   placeholder:     String | nil                   (default: nil)
    #   character_count: Boolean                        (default: false)
    #   readonly:        Boolean                        (default: false)
    #   autofocus:       Boolean                        (default: false)
    #   mentions:        Boolean | Hash                 (default: false)
    #   uploads:         Boolean | Hash                 (default: false)
    #   tables:          Boolean | Hash                 (default: false)
    #   collaboration:   Boolean | Hash                 (default: false)
    #   extensions:      Hash of per-extension overrides (default: {})
    #   ui:              Hash for TipTap UI presentation hints (default: {})
    #
    # == Format semantics
    #
    #   :json — canonical internal format; stores TipTap JSON document; recommended for persistence
    #   :html — stores rendered HTML; requires sanitization before display
    #
    # == Preset definitions (see extension_registry.js for the JS side)
    #
    #   :minimal  — StarterKit, Placeholder, BubbleMenu, CharacterCount, Link, Underline, TextAlign
    #   :content  — minimal + Highlight, TextStyle, Color, BackgroundColor, Typography, Image,
    #               CodeBlockLowlight, TaskList, TaskItem, Table (via TableKit)
    #   :full     — content + FontFamily, Subscript, Superscript, Mention, Mathematics, Emoji,
    #               Audio, YouTube, Details, Collaboration, DragHandle, UniqueID, FloatingMenu,
    #               InvisibleCharacters, TrailingNode, ListKeymap, Focus
    #
    # == Framework-specific TipTap wrappers (NOT applicable to FlatPack)
    #
    #   @tiptap-ui/react drag-handle and @tiptap-ui/vue drag-handle are React/Vue component
    #   wrappers for the TipTap DragHandle extension. FlatPack uses vanilla JS + Stimulus and
    #   integrates the core @tiptap/extension-drag-handle directly without any framework wrapper.
    #   Do not attempt to use React/Vue TipTap UI wrappers in a FlatPack application.
    #
    class RichTextOptions
      VALID_FORMATS          = %i[json html].freeze
      VALID_PRESETS          = %i[minimal content full].freeze
      VALID_TOOLBAR_PRESETS  = %i[minimal standard full none].freeze

      DEFAULTS = {
        format:          :json,
        preset:          :minimal,
        toolbar:         :standard,
        bubble_menu:     true,
        floating_menu:   false,
        placeholder:     nil,
        character_count: false,
        readonly:        false,
        autofocus:       false,
        mentions:        false,
        uploads:         false,
        tables:          false,
        collaboration:   false,
        extensions:      {},
        ui:              {}
      }.freeze

      attr_reader :options

      def initialize(raw = {})
        raw = {} if raw.nil?
        unless raw.is_a?(Hash)
          raise ArgumentError, "rich_text_options must be a Hash, got #{raw.class}"
        end

        @options = normalize_and_validate(raw.transform_keys(&:to_sym))
      end

      # Returns the normalized options Hash.
      def to_h
        @options
      end

      # Returns a deep-serialized Hash safe for JSON data-attribute embedding.
      # Symbols become Strings; nested Hashes and Arrays are recursively serialized.
      def for_json
        deep_serialize(@options)
      end

      private

      def normalize_and_validate(opts)
        result = DEFAULTS.merge(opts)

        # Normalize enum fields to Symbol (allow String input)
        result[:format]  = normalize_sym(result[:format])
        result[:preset]  = normalize_sym(result[:preset])
        result[:toolbar] = result[:toolbar].is_a?(Array) ? result[:toolbar] : normalize_sym(result[:toolbar])

        validate_format!(result[:format])
        validate_preset!(result[:preset])
        validate_toolbar!(result[:toolbar])
        validate_boolean!(:bubble_menu,     result[:bubble_menu])
        validate_boolean!(:floating_menu,   result[:floating_menu])
        validate_boolean!(:character_count, result[:character_count])
        validate_boolean!(:readonly,        result[:readonly])
        validate_boolean!(:autofocus,       result[:autofocus])
        validate_flex_config!(:mentions,     result[:mentions])
        validate_flex_config!(:uploads,      result[:uploads])
        validate_flex_config!(:tables,       result[:tables])
        validate_flex_config!(:collaboration, result[:collaboration])
        validate_extensions!(result[:extensions])
        validate_ui!(result[:ui])
        validate_placeholder!(result[:placeholder])

        result
      end

      def normalize_sym(value)
        value.to_sym
      rescue
        value
      end

      def validate_format!(value)
        return if VALID_FORMATS.include?(value)

        raise ArgumentError,
          "rich_text_options[:format] must be one of #{VALID_FORMATS.map(&:inspect).join(", ")}, " \
          "got #{value.inspect}"
      end

      def validate_preset!(value)
        return if VALID_PRESETS.include?(value)

        raise ArgumentError,
          "rich_text_options[:preset] must be one of #{VALID_PRESETS.map(&:inspect).join(", ")}, " \
          "got #{value.inspect}"
      end

      def validate_toolbar!(value)
        return if value.is_a?(Array)
        return if VALID_TOOLBAR_PRESETS.include?(value)

        raise ArgumentError,
          "rich_text_options[:toolbar] must be one of " \
          "#{VALID_TOOLBAR_PRESETS.map(&:inspect).join(", ")} or an Array of tool names, " \
          "got #{value.inspect}"
      end

      def validate_boolean!(key, value)
        return if [true, false].include?(value)

        raise ArgumentError,
          "rich_text_options[:#{key}] must be true or false, got #{value.inspect}"
      end

      def validate_flex_config!(key, value)
        return if [true, false].include?(value) || value.is_a?(Hash)

        raise ArgumentError,
          "rich_text_options[:#{key}] must be true, false, or a Hash of config, " \
          "got #{value.class}"
      end

      def validate_extensions!(value)
        return if value.is_a?(Hash)

        raise ArgumentError,
          "rich_text_options[:extensions] must be a Hash of extension configs, got #{value.class}"
      end

      def validate_ui!(value)
        return if value.is_a?(Hash)

        raise ArgumentError,
          "rich_text_options[:ui] must be a Hash of UI presentation config, got #{value.class}"
      end

      def validate_placeholder!(value)
        return if value.nil? || value.is_a?(String)

        raise ArgumentError,
          "rich_text_options[:placeholder] must be a String or nil, got #{value.class}"
      end

      def deep_serialize(val)
        case val
        when Symbol then val.to_s
        when Hash   then val.transform_keys(&:to_s).transform_values { |v| deep_serialize(v) }
        when Array  then val.map { |v| deep_serialize(v) }
        else             val
        end
      end
    end
  end
end
