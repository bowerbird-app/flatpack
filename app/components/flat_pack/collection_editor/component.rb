# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    class Component < FlatPack::BaseComponent
      renders_many :rows, "FlatPack::CollectionEditor::Row::Component"
      renders_one :template

      HANDLE_SELECTOR = "[data-collection-editor-handle]"

      def initialize(
        title: nil,
        add_label: "Add",
        empty_text: "Nothing here yet",
        headers: nil,
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
        @add_label = add_label.to_s.presence || "Add"
        @empty_text = empty_text.to_s.presence || "Nothing here yet"
        @headers = Array(headers).map { |header| header.to_s }.presence
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
            render_headers,
            render_list,
            render_empty,
            render_template,
            render_add
          ].compact)
        end
      end

      private

      def section_attributes
        attrs = {
          class: section_classes,
          data: {
            controller: merge_space_tokens(data_attributes[:controller] || data_attributes["controller"], "flat-pack--collection-editor"),
            flat_pack__collection_editor_template_index_value: @template_index
          }
        }
        attrs[:aria] = {labelledby: @title_id} if @title.present?
        merge_attributes(**attrs)
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

      def render_headers
        return if @headers.blank?

        content_tag(:div, class: "flat-pack-collection-editor-header", aria: {hidden: "true"}) do
          safe_join([
            content_tag(:span, ""),
            safe_join(@headers.map { |header| content_tag(:span, header) }),
            content_tag(:span, "")
          ])
        end
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

      def render_add
        render FlatPack::Button::Component.new(
          text: @add_label,
          icon: "plus",
          style: :secondary,
          size: :sm,
          type: "button",
          data: {
            flat_pack__collection_editor_target: "addButton",
            action: "click->flat-pack--collection-editor#add"
          }
        )
      end

      def visible_rows?
        rows.any? { |row| !row.destroyed_row? }
      end
    end
  end
end
