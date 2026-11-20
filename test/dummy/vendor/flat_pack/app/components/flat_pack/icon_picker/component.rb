# frozen_string_literal: true

require "digest"

module FlatPack
  module IconPicker
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles

      VARIANTS = FlatPack::Heroicons::VARIANTS.map(&:to_sym).freeze

      def initialize(
        name:,
        value: nil,
        icons: nil,
        variant: :outline,
        label: nil,
        placeholder: FlatPack::Copy::OMITTED,
        search_placeholder: FlatPack::Copy::OMITTED,
        include_blank: false,
        show_name: nil,
        chrome: :field,
        disabled: false,
        required: false,
        error: nil,
        help_text: nil,
        **system_arguments
      )
        assign_control_chrome!(chrome)
        @supplied_id = system_arguments.delete(:id)
        @custom_class = system_arguments.delete(:class)
        super(**system_arguments)
        @name = name
        @variant = variant.to_sym
        @label = label
        @placeholder = fp_text(placeholder, "icon_picker.placeholder")
        @search_placeholder = fp_text(search_placeholder, "icon_picker.search_placeholder")
        @include_blank = include_blank
        @disabled = disabled
        @required = required
        @error = error
        @help_text = normalize_help_text!(help_text)
        @names = resolve_names(icons)
        @selected_name = accepted_value(value)
        @show_name = show_name.nil? ? !cell_chrome? : ActiveModel::Type::Boolean.new.cast(show_name)

        validate!
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: field_id,
          class: "flat-pack-input-wrapper"
        ) do |field|
          field.with_control { render_control }
        end
      end

      private

      def render_control
        content_tag(:div, class: "relative", data: controller_data) do
          safe_join([
            render_hidden_input,
            render_trigger,
            render_panel,
            render_catalog
          ])
        end
      end

      def controller_data
        {
          controller: "flat-pack--icon-picker",
          flat_pack__icon_picker_catalog_id_value: catalog_dom_id,
          flat_pack__icon_picker_show_name_value: @show_name,
          flat_pack__icon_picker_placeholder_value: @placeholder
        }
      end

      def render_hidden_input
        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        aria = {}
        aria[:describedby] = describedby if describedby.present?
        aria[:invalid] = "true" if @error

        tag.input(
          type: "hidden",
          name: @name,
          id: "#{field_id}_value",
          value: @selected_name.to_s,
          disabled: @disabled,
          required: @required,
          data: {flat_pack__icon_picker_target: "hidden"},
          aria: aria
        )
      end

      def render_trigger
        content_tag(:button, type: "button", id: field_id, class: trigger_classes, disabled: @disabled, data: trigger_data, aria: trigger_aria) do
          safe_join([
            content_tag(:span, class: "flex min-w-0 items-center gap-2") do
              safe_join([
                render_trigger_icon,
                content_tag(:span, trigger_label, class: "fp-icon-picker__label block min-w-0 truncate", hidden: !show_label?, data: {flat_pack__icon_picker_target: "valueLabel"})
              ])
            end,
            render_chevron
          ].compact)
        end
      end

      def render_trigger_icon
        content_tag(:span, class: "inline-flex shrink-0", hidden: @selected_name.blank?, data: {flat_pack__icon_picker_target: "valueIcon"}) do
          if @selected_name.present?
            render FlatPack::Shared::IconComponent.new(name: @selected_name, size: :sm, variant: @variant)
          end
        end
      end

      def render_chevron
        return if cell_chrome?

        content_tag(:span, class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3") do
          render FlatPack::Shared::IconComponent.new(
            name: "chevron-down",
            size: :sm,
            class: "text-[var(--surface-muted-content-color)]"
          )
        end
      end

      def render_panel
        content_tag(
          :div,
          id: panel_id,
          class: "fp-icon-picker__panel hidden",
          role: "dialog",
          inert: true,
          aria: {label: fp_t("icon_picker.dialog"), hidden: "true"},
          data: {flat_pack__icon_picker_target: "panel"}
        ) do
          safe_join([
            tag.input(
              type: "text",
              class: "fp-icon-picker__search",
              placeholder: @search_placeholder,
              autocomplete: "off",
              aria: {label: @search_placeholder},
              data: {flat_pack__icon_picker_target: "search"}
            ),
            render_clear,
            content_tag(:div, "", class: "fp-icon-picker__grid", role: "group", aria: {label: fp_t("icon_picker.icons")}, data: {flat_pack__icon_picker_target: "grid"}),
            content_tag(:p, fp_t("icon_picker.empty"), class: "fp-icon-picker__empty", hidden: true, data: {flat_pack__icon_picker_target: "empty"})
          ].compact)
        end
      end

      def render_clear
        return unless blank_choice?

        content_tag(
          :button,
          blank_label,
          type: "button",
          class: "fp-icon-picker__clear",
          aria: {pressed: @selected_name.blank?.to_s},
          data: {flat_pack__icon_picker_target: "clear"}
        )
      end

      def render_catalog
        registry = catalog_registry
        return "".html_safe if registry[catalog_key]

        registry[catalog_key] = true
        content_tag(:template, id: catalog_dom_id) do
          safe_join(@names.map { |icon_name| render_option(icon_name) })
        end
      end

      def render_option(icon_name)
        content_tag(
          :button,
          type: "button",
          class: "fp-icon-picker__option",
          tabindex: "-1",
          aria: {
            label: human_name(icon_name),
            pressed: (icon_name == @selected_name).to_s
          },
          data: {
            icon_name: icon_name,
            icon_search: search_key(icon_name)
          }
        ) do
          render FlatPack::Shared::IconComponent.new(name: icon_name, size: :sm, variant: @variant)
        end
      end

      def catalog_registry
        registry = helpers.instance_variable_get(:@_flat_pack_icon_catalogs)
        return registry if registry

        registry = {}
        helpers.instance_variable_set(:@_flat_pack_icon_catalogs, registry)
        registry
      end

      def catalog_key
        "#{@variant}:#{catalog_digest}"
      end

      def catalog_digest
        @catalog_digest ||= Digest::SHA256.hexdigest(@names.join("\n"))[0, 12]
      end

      def catalog_dom_id
        "flat-pack-icon-catalog-#{@variant}-#{catalog_digest}"
      end

      def trigger_data
        {
          action: "click->flat-pack--icon-picker#toggle keydown->flat-pack--icon-picker#triggerKey",
          flat_pack__icon_picker_target: "trigger",
          empty: (@selected_name.blank? ? "true" : "false")
        }
      end

      def trigger_aria
        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        aria = {
          haspopup: "dialog",
          expanded: "false",
          controls: panel_id,
          label: trigger_label
        }
        aria[:describedby] = describedby if describedby.present?
        aria[:invalid] = "true" if @error
        aria
      end

      def trigger_classes
        form_control_classes(
          error: @error,
          custom_class: @custom_class,
          control_class: "fp-icon-picker__trigger",
          placeholder: false,
          extra: [
            "relative",
            "inline-flex",
            "items-center",
            "text-left",
            ("pr-10" unless cell_chrome?)
          ]
        )
      end

      def trigger_label
        @selected_name.present? ? human_name(@selected_name) : @placeholder
      end

      def show_label?
        @selected_name.blank? || @show_name
      end

      def field_id
        @field_id ||= @supplied_id.presence || "icon_picker_#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def panel_id
        "#{field_id}_panel"
      end

      def help_text_id
        "#{field_id}_help_text"
      end

      def error_id
        "#{field_id}_error"
      end

      def blank_choice?
        @include_blank == true || (@include_blank.is_a?(String) && @include_blank.present?)
      end

      def blank_label
        return @include_blank if @include_blank.is_a?(String) && @include_blank.present?

        fp_t("icon_picker.clear")
      end

      def human_name(icon_name)
        icon_name.to_s.tr("-", " ").sub(/\A\w/, &:upcase)
      end

      def search_key(icon_name)
        icon_name.to_s.downcase.gsub(/[-\s]+/, "")
      end

      def resolve_names(icons)
        raise ArgumentError, "icons must be an Array of icon names" unless icons.nil? || icons.is_a?(Array)
        raise ArgumentError, "icons must include at least one name" if icons.is_a?(Array) && icons.empty?

        source = icons.nil? ? FlatPack::Heroicons.names(@variant) : icons
        source.map { |icon_name| canonical_name(icon_name) }.uniq
      end

      def accepted_value(value)
        return if value.blank?

        candidate = canonical_name(value)
        candidate if @names.include?(candidate)
      end

      def canonical_name(icon_name)
        raw = icon_name.to_s.tr("_", "-")
        FlatPack::Shared::IconComponent::NAME_MAP.fetch(raw, raw)
      end

      def validate!
        raise ArgumentError, "name is required" if @name.blank?
        unless VARIANTS.include?(@variant)
          raise ArgumentError, "variant must be one of: #{VARIANTS.join(", ")}"
        end
        unless @include_blank == true || @include_blank == false || @include_blank.nil? || @include_blank.is_a?(String)
          raise ArgumentError, "include_blank must be true, false, or a String"
        end

        bank = FlatPack::Heroicons.banks.fetch(@variant.to_s)
        unknown = @names.reject { |icon_name| bank.key?(icon_name) }
        return if unknown.empty?

        raise ArgumentError, "Unknown icon \"#{unknown.first}\" for variant :#{@variant}"
      end
    end
  end
end
