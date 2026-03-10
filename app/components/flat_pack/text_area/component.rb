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
        rich_text_editor: false,
        rich_text_editor_options: {},
        rich_text_editor_mode: :inline,
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
        @rich_text_editor = rich_text_editor
        @rich_text_editor_mode = normalize_rich_text_editor_mode(rich_text_editor_mode)
        @rich_text_editor_options = normalize_rich_text_editor_options(rich_text_editor_options)

        validate_name!
        validate_rows!
        validate_character_limits!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            render_label,
            render_textarea,
            render_character_count,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(textarea_id, @label, class: label_classes)
      end

      def render_textarea
        content_tag(:textarea, textarea_value, **textarea_attributes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

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

      def textarea_attributes
        attrs = {
          name: @name,
          id: textarea_id,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          rows: @rows,
          class: textarea_classes,
          data: textarea_data_attributes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def wrapper_attributes
        {
          class: wrapper_classes,
          data: wrapper_data_attributes
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

      def textarea_value
        return @value unless rich_text_editor?

        @textarea_value ||= sanitize_rich_text_value(@value)
      end

      def error_id
        "#{textarea_id}_error"
      end

      def character_count_id
        "#{textarea_id}_character_count"
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
        actions.join(" ")
      end

      def rich_text_editor?
        @rich_text_editor
      end

      def wrapper_data_attributes
        return text_area_wrapper_data_attributes unless rich_text_editor?

        {
          controller: "flat-pack--rich-text-editor",
          flat_pack__rich_text_editor_mode_value: @rich_text_editor_mode,
          flat_pack__rich_text_editor_config_value: @rich_text_editor_options.to_json
        }.compact
      end

      def text_area_wrapper_data_attributes
        {
          controller: "flat-pack--text-area",
          flat_pack__text_area_autogrow_value: @autogrow,
          flat_pack__text_area_submit_on_enter_value: @submit_on_enter,
          flat_pack__text_area_min_characters_value: @min_characters,
          flat_pack__text_area_max_characters_value: @max_characters,
          flat_pack__text_area_character_count_enabled_value: @character_count
        }.compact
      end

      def textarea_data_attributes
        return rich_text_textarea_data_attributes if rich_text_editor?

        {
          flat_pack__text_area_target: "textarea",
          action: textarea_actions
        }.compact
      end

      def rich_text_textarea_data_attributes
        {
          flat_pack__rich_text_editor_target: "textarea"
        }.compact
      end

      def normalize_rich_text_editor_mode(mode)
        normalized_mode = mode.to_s.presence || "inline"

        return normalized_mode if normalized_mode == "inline"

        raise ArgumentError, "rich_text_editor_mode must be inline"
      end

      def normalize_rich_text_editor_options(options)
        return {} unless rich_text_editor?
        raise ArgumentError, "rich_text_editor_options must be a Hash" unless options.is_a?(Hash)

        options.each_with_object({}) do |(key, value), normalized|
          case key.to_s
          when "toolbar_groups", "toolbarGroups"
            toolbar_groups = normalize_toolbar_groups(value)
            normalized["toolbarGroups"] = toolbar_groups if toolbar_groups.present?
          when "balloon_toolbar", "balloonToolbar"
            balloon_toolbar = normalize_editor_string_list(value)
            normalized["balloonToolbar"] = balloon_toolbar if balloon_toolbar.present?
          when "placeholder"
            placeholder = value.to_s.strip
            normalized["placeholder"] = placeholder if placeholder.present?
          when "height"
            height = normalize_height(value)
            normalized["height"] = height if height.present?
          when "extra_plugins", "extraPlugins"
            extra_plugins = normalize_editor_string_list(value)
            normalized["extraPlugins"] = extra_plugins if extra_plugins.present?
          when "remove_plugins", "removePlugins"
            remove_plugins = normalize_editor_string_list(value)
            normalized["removePlugins"] = remove_plugins if remove_plugins.present?
          when "content_css", "contentCss", "contentsCss"
            contents_css = normalize_contents_css(value)
            normalized["contentsCss"] = contents_css if contents_css.present?
          end
        end
      end

      def normalize_toolbar_groups(value)
        Array.wrap(value).filter_map do |group|
          if group.is_a?(Hash)
            name = normalize_editor_identifier(group[:name] || group["name"])
            groups = normalize_editor_string_list(group[:groups] || group["groups"])
            next if name.blank?

            normalized_group = {"name" => name}
            normalized_group["groups"] = groups if groups.present?
            normalized_group
          else
            normalize_editor_identifier(group)
          end
        end
      end

      def normalize_editor_string_list(value)
        Array.wrap(value).flat_map { |item| item.to_s.split(",") }.filter_map do |item|
          normalize_editor_identifier(item)
        end.uniq
      end

      def normalize_contents_css(value)
        Array.wrap(value).flat_map { |item| item.to_s.split(",") }.filter_map do |item|
          normalized_item = item.to_s.strip
          next if normalized_item.blank?
          next unless normalized_item.match?(/\A[\w\-.:\/]+\z/)

          normalized_item
        end.uniq
      end

      def normalize_height(value)
        case value
        when Integer
          "#{value}px" if value.positive?
        else
          string_value = value.to_s.strip
          return if string_value.blank?
          return unless string_value.match?(/\A\d+(px|rem|em|vh|%)?\z/)

          string_value.match?(/\A\d+\z/) ? "#{string_value}px" : string_value
        end
      end

      def normalize_editor_identifier(value)
        identifier = value.to_s.strip
        return if identifier.blank?
        return unless identifier.match?(/\A[\w-]+\z/)

        identifier
      end

      def sanitize_rich_text_value(value)
        pruned_html = Loofah.fragment(value.to_s).scrub!(:prune).to_s

        ActionController::Base.helpers.sanitize(
          pruned_html,
          tags: %w[p br strong em u s ul ol li a blockquote code pre h2 h3 h4],
          attributes: %w[href target rel]
        )
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
