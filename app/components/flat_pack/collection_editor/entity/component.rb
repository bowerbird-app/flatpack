# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    module Entity
      class Component < FlatPack::BaseComponent
        attr_reader :search_url, :search_param, :min_search_length, :create_url,
          :create_label, :empty_text, :edit_url_template, :title, :description

        def initialize(
          form:,
          association_name:,
          title: nil,
          description: nil,
          value: nil,
          label: nil,
          search_url: nil,
          search_param: "q",
          min_search_length: 1,
          create_url: nil,
          create_label: "Create",
          search_placeholder: "Search",
          empty_text: "No matches",
          search_error_text: "Search failed",
          items: nil,
          edit_url_template: nil,
          edit_label: "Edit",
          change_label: "Change",
          error: nil,
          open: false,
          **system_arguments
        )
          super(**system_arguments)
          @form = form
          @association_name = association_name
          @title = title.to_s.presence
          @description = description.to_s.presence
          @value = value
          @label = label.to_s.presence || "Record"
          @search_url = sanitize_endpoint(search_url)
          @search_param = search_param.to_s.presence || "q"
          @min_search_length = min_search_length.to_i
          @create_url = sanitize_endpoint(create_url)
          @create_label = create_label.to_s.presence || "Create"
          @search_placeholder = search_placeholder.to_s
          @empty_text = empty_text.to_s.presence || "No matches"
          @search_error_text = search_error_text.to_s.presence || "Search failed"
          @items = items
          @edit_url_template = sanitize_endpoint(edit_url_template)
          @edit_label = edit_label.to_s.presence || "Edit"
          @change_label = change_label.to_s.presence || "Change"
          @error = error.to_s.presence
          @open = open || @title.blank?
          @list_id = "fp-collection-editor-#{form.field_id(association_name)}-results"
          @search_id = "fp-collection-editor-#{form.field_id(association_name)}-search"
        end

        def items_json
          return if @items.nil?

          Array(@items).to_json
        end

        def call
          content_tag(:div, **entity_attributes) do
            safe_join([
              association_field,
              render_summary,
              render_panel,
              render_error
            ].compact)
          end
        end

        private

        def entity_attributes
          merge_attributes(class: "flat-pack-collection-editor-entity")
        end

        def association_field
          options = {data: {collection_editor_association: "true"}}
          options[:value] = @value unless @value.nil?
          @form.hidden_field(@association_name, options)
        end

        def render_summary
          content_tag(:div, class: "flat-pack-collection-editor-summary", data: {collection_editor_summary: "true"}, hidden: @title.blank?) do
            safe_join([
              content_tag(:p, @title, class: "flat-pack-collection-editor-title", data: {collection_editor_title: "true"}),
              (@description.present? ? content_tag(:p, @description, class: "flat-pack-collection-editor-description", data: {collection_editor_description: "true"}) : content_tag(:p, "", class: "flat-pack-collection-editor-description", data: {collection_editor_description: "true"}, hidden: true)),
              render_edit_link,
              render_change_button
            ].compact)
          end
        end

        def render_edit_link
          return if @edit_url_template.blank?

          link_to(
            @edit_label,
            edit_href || "#",
            class: "flat-pack-collection-editor-edit",
            data: {collection_editor_edit: "true"},
            hidden: edit_href.blank?
          )
        end

        def edit_href
          return if @edit_url_template.blank? || current_value.blank?

          @edit_url_template.gsub(":id", ERB::Util.url_encode(current_value.to_s))
        end

        def current_value
          return @value unless @value.nil?

          object = @form.object
          return unless object.respond_to?(@association_name)

          object.public_send(@association_name).presence
        end

        def render_change_button
          button_tag(
            type: "button",
            class: "flat-pack-collection-editor-change",
            data: {
              collection_editor_change: "true",
              action: "click->flat-pack--collection-editor#openPicker"
            },
            hidden: @title.blank?
          ) { @change_label }
        end

        def render_panel
          content_tag(:div, class: "flat-pack-collection-editor-panel", data: {collection_editor_panel: "true"}, hidden: !@open) do
            safe_join([
              render_search,
              content_tag(:p, @empty_text, class: "flat-pack-collection-editor-no-results", data: {collection_editor_no_results: "true"}, hidden: true),
              content_tag(:p, @search_error_text, class: "flat-pack-collection-editor-search-error", role: "alert", data: {collection_editor_search_error: "true"}, hidden: true),
              render_create_button,
              render_create_fields,
              content_tag(:p, "", class: "flat-pack-collection-editor-create-error", role: "alert", data: {collection_editor_create_error: "true"}, hidden: true)
            ].compact)
          end
        end

        def render_search
          content_tag(:div, class: "flat-pack-collection-editor-search") do
            safe_join([
              content_tag(:label, @label, for: @search_id, class: "flat-pack-collection-editor-sr"),
              tag.input(
                id: @search_id,
                type: "search",
                class: "flat-pack-collection-editor-search-input",
                placeholder: @search_placeholder,
                autocomplete: "off",
                spellcheck: "false",
                role: "combobox",
                aria: {
                  expanded: @open ? "true" : "false",
                  controls: @list_id,
                  autocomplete: "list",
                  haspopup: "listbox"
                },
                data: {
                  collection_editor_search: "true",
                  action: "input->flat-pack--collection-editor#search keydown->flat-pack--collection-editor#searchKeydown focus->flat-pack--collection-editor#openPicker"
                }
              ),
              content_tag(:div, "", id: @list_id, class: "flat-pack-collection-editor-results", role: "listbox", data: {collection_editor_results: "true"})
            ])
          end
        end

        def render_create_button
          return if @create_url.blank?

          button_tag(
            type: "button",
            class: "flat-pack-collection-editor-create",
            data: {
              collection_editor_create_button: "true",
              action: "click->flat-pack--collection-editor#promptCreate"
            }
          ) do
            content_tag(:span, @create_label, data: {collection_editor_create_label: "true"})
          end
        end

        def render_create_fields
          return unless content?

          content_tag(:div, class: "flat-pack-collection-editor-create-fields", data: {collection_editor_create_fields: "true"}, hidden: true) do
            safe_join([
              content,
              button_tag(
                type: "button",
                class: "flat-pack-collection-editor-create-submit",
                data: {action: "click->flat-pack--collection-editor#create"}
              ) { @create_label }
            ])
          end
        end

        def render_error
          return if @error.blank?

          content_tag(:p, @error, class: "flat-pack-collection-editor-error", role: "alert")
        end

        def sanitize_endpoint(url)
          FlatPack::AttributeSanitizer.sanitize_url(url)
        end
      end
    end
  end
end
