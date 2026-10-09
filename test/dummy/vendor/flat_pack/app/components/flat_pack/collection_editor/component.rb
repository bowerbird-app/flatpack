# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    class Component < FlatPack::BaseComponent
      renders_many :rows, "FlatPack::CollectionEditor::Row::Component"
      renders_one :template

      HANDLE_SELECTOR = "[data-collection-editor-handle]"

      def initialize(
        title: nil,
        add_label: "Row",
        empty_text: "Nothing here yet",
        headers: nil,
        column_widths: nil,
        orderable: false,
        orderable_url: nil,
        orderable_method: :patch,
        param_uuid_name: "id",
        param_target_position_name: "position",
        template_index: "NEW_RECORD",
        **system_arguments
      )
        super(**system_arguments)
        @title = title.to_s.presence
        @add_label = add_label.to_s.presence || "Row"
        @empty_text = empty_text.to_s.presence || "Nothing here yet"
        @headers = Array(headers).map { |header| header.to_s }.presence
        @column_widths = validated_column_widths!(column_widths)
        @orderable = orderable
        @orderable_url = orderable_url
        @orderable_method = orderable_method
        @param_uuid_name = param_uuid_name
        @param_target_position_name = param_target_position_name
        @template_index = template_index.to_s.presence || "NEW_RECORD"
        @title_id = "fp-collection-editor-#{SecureRandom.hex(4)}"
      end

      def call
        content
        content_tag(:section, **section_attributes) do
          safe_join([
            render_title,
            render_card,
            render_template,
            render_status
          ].compact)
        end
      end

      private

      def section_attributes
        attrs = {
          class: section_classes,
          style: section_style,
          data: {
            controller: merge_space_tokens(data_attributes[:controller] || data_attributes["controller"], "flat-pack--collection-editor"),
            flat_pack__collection_editor_template_index_value: @template_index
          }
        }
        attrs[:aria] = {labelledby: @title_id} if @title.present?
        merge_attributes(**attrs)
      end

      def section_style
        columns = "--collection-editor-columns: #{column_template}"
        host = @system_arguments[:style]
        return columns if host.blank?

        "#{host.to_s.sub(/;\s*\z/, "")}; #{columns}"
      end

      def column_template
        parts = []
        parts << "auto" if @orderable
        parts.concat(content_tracks)
        parts << "auto"
        parts.join(" ")
      end

      def content_tracks
        return @column_widths if @column_widths

        count = @headers.present? ? @headers.length : 2
        Array.new(count) { |index| index.zero? ? "minmax(0, 1.4fr)" : "minmax(8rem, 1fr)" }
      end

      def validated_column_widths!(column_widths)
        return if column_widths.nil?

        tracks = Array(column_widths).map { |track| track.to_s.strip }
        return if tracks.empty?

        sanitized = tracks.map { |track| sanitize_column_width!(track) }
        if @headers.present? && sanitized.length != @headers.length
          entries = "entry".pluralize(sanitized.length)
          raise ArgumentError, "column_widths has #{sanitized.length} #{entries} and headers has #{@headers.length}."
        end

        sanitized
      end

      def sanitize_column_width!(track)
        safe = FlatPack::AttributeSanitizer.sanitize_css_grid_track(track)
        return safe if safe

        raise ArgumentError, "Invalid column_widths: #{track.inspect}. Must be a CSS grid track such as \"minmax(8rem, 1fr)\" or \"max-content\"."
      end

      def section_classes
        classes(
          "flat-pack-collection-editor",
          ("flat-pack-collection-editor--headed" if @headers.present?),
          ("flat-pack-collection-editor--orderable" if @orderable)
        )
      end

      def render_title
        return if @title.blank?

        content_tag(:h2, @title, id: @title_id, class: "flat-pack-collection-editor-heading")
      end

      def render_card
        content_tag(:div, class: "flat-pack-collection-editor-card") do
          safe_join([render_headers, render_list, render_empty, render_add].compact)
        end
      end

      def render_headers
        return if @headers.blank?

        cells = []
        cells << content_tag(:span, "") if @orderable
        cells.concat(@headers.map { |header| content_tag(:span, header) })
        cells << content_tag(:span, "")
        content_tag(:div, safe_join(cells), class: "flat-pack-collection-editor-header", aria: {hidden: "true"})
      end

      def render_list
        content_tag(:ul, safe_join(rows), **list_attributes)
      end

      def list_attributes
        data = {flat_pack__collection_editor_target: "list"}
        if @orderable
          data[:controller] = "flat-pack--list-orderable"
          data[:flat_pack__list_orderable_handle_selector_value] = HANDLE_SELECTOR
          data[:flat_pack__list_orderable_orderable_url_value] = @orderable_url if @orderable_url.present?
          data[:flat_pack__list_orderable_orderable_method_value] = @orderable_method.to_s.upcase if @orderable_method.present?
          data[:flat_pack__list_orderable_param_uuid_name_value] = @param_uuid_name if @param_uuid_name.present?
          data[:flat_pack__list_orderable_param_target_position_name_value] = @param_target_position_name if @param_target_position_name.present?
        end

        {
          class: list_classes,
          role: "list",
          data: data
        }
      end

      def list_classes
        [
          "flat-pack-list",
          "flat-pack-collection-editor-rows",
          ("flat-pack-list--orderable" if @orderable)
        ].compact.join(" ")
      end

      def render_empty
        content_tag(
          :p,
          @empty_text,
          class: "flat-pack-collection-editor-empty",
          data: {flat_pack__collection_editor_target: "empty"},
          hidden: visible_rows?
        )
      end

      def render_template
        return unless template?

        content_tag(:template, template.to_s.html_safe, data: {flat_pack__collection_editor_target: "template"})
      end

      def render_status
        content_tag(
          :p,
          "",
          class: "flat-pack-collection-editor-sr",
          role: "status",
          aria: {live: "polite"},
          data: {flat_pack__collection_editor_target: "status"}
        )
      end

      def render_add
        content_tag(:div, class: "flat-pack-collection-editor-add") do
          render FlatPack::Button::Component.new(
            text: @add_label,
            icon: "plus",
            style: :ghost,
            size: :sm,
            type: "button",
            data: {
              flat_pack__collection_editor_target: "addButton",
              action: "click->flat-pack--collection-editor#add"
            }
          )
        end
      end

      def visible_rows?
        rows.any? { |row| !row.destroyed_row? }
      end
    end
  end
end
