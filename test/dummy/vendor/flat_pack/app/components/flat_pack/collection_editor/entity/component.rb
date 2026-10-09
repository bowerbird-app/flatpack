# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    module Entity
      class Component < FlatPack::BaseComponent
        attr_reader :search_url, :search_param, :min_search_length, :create_url,
          :create_label, :empty_text, :edit_url_template, :edit_label, :change_label,
          :update_url, :update_label, :title, :description

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
          edit_label: nil,
          change_label: "Change",
          update_url: nil,
          update_label: nil,
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
          @edit_label = edit_label.to_s.presence || FlatPack::Copy.t("common.edit")
          @change_label = change_label.to_s.presence || "Change"
          @update_url = update_endpoint(update_url)
          @update_label = update_label.to_s.presence || FlatPack::Copy.t("common.save")
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
              render_create_modal,
              render_error
            ].compact)
          end
        end

        private

        def entity_attributes
          data = {results_id: @list_id}
          data[:create_modal_id] = create_modal_id if dialog?

          merge_attributes(
            class: "flat-pack-collection-editor-entity",
            data: data
          )
        end

        def association_field
          options = {data: {collection_editor_association: "true"}}
          options[:value] = @value unless @value.nil?
          @form.hidden_field(@association_name, options)
        end

        def render_summary
          content_tag(:div, class: "flat-pack-collection-editor-summary", data: {collection_editor_summary: "true"}, hidden: @title.blank?) do
            safe_join([
              render_chip,
              content_tag(:p, @description.to_s, class: "flat-pack-collection-editor-description", data: {collection_editor_description: "true"}, hidden: true)
            ])
          end
        end

        def render_chip
          render FlatPack::Chip::Component.new(
            style: :info,
            removable: true,
            value: current_value,
            class: "flat-pack-collection-editor-chip"
          ) do |chip|
            chip.remove_button { render_chip_remove }
            render_chip_name
          end
        end

        def render_chip_name
          title = content_tag(:span, @title, data: {collection_editor_title: "true"})
          return title unless editable?

          button_tag(
            type: "button",
            class: "flat-pack-collection-editor-name",
            aria: {label: chip_edit_label},
            data: {
              collection_editor_edit: "true",
              action: "click->flat-pack--collection-editor#edit"
            }
          ) { title }
        end

        def chip_edit_label
          @title.present? ? "#{@edit_label} #{@title}" : @edit_label
        end

        def render_chip_remove
          button_tag(
            type: "button",
            class: "ml-1 inline-flex items-center justify-center rounded-full fp-hit-target-inline hover:bg-[var(--chip-remove-hover-background-color)]",
            aria: {label: chip_remove_label},
            data: {
              collection_editor_chip_remove: "true",
              action: "click->flat-pack--collection-editor#remove"
            }
          ) do
            content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-3 w-3", viewBox: "0 0 20 20", fill: "currentColor", aria: {hidden: "true"}) do
              content_tag(:path, nil, "fill-rule": "evenodd", d: "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z", "clip-rule": "evenodd")
            end
          end
        end

        def chip_remove_label
          @title.present? ? "Remove #{@title}" : "Remove"
        end

        def current_value
          return @value unless @value.nil?

          object = @form.object
          return unless object.respond_to?(@association_name)

          object.public_send(@association_name).presence
        end

        def render_panel
          content_tag(:div, class: "flat-pack-collection-editor-panel", data: {collection_editor_panel: "true"}, hidden: !@open) do
            safe_join([
              render_search,
              content_tag(:p, @empty_text, class: "flat-pack-collection-editor-no-results", data: {collection_editor_no_results: "true"}, hidden: true),
              content_tag(:p, @search_error_text, class: "flat-pack-collection-editor-search-error", role: "alert", data: {collection_editor_search_error: "true"}, hidden: true)
            ])
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

        def creatable?
          content? && @create_url.present?
        end

        public

        def editable?
          content? && @update_url.present?
        end

        def dialog?
          content? && (@create_url.present? || @update_url.present?)
        end

        def create_title
          FlatPack::Copy.t("collection_editor.new_record", label: @label)
        end

        def edit_title
          FlatPack::Copy.t("collection_editor.edit_record", label: @label)
        end

        private

        def create_modal_id
          "fp-collection-editor-#{@form.field_id(@association_name)}-create"
        end

        def create_modal_title
          create_title
        end

        def render_create_modal
          return unless dialog?

          render FlatPack::Modal::Component.new(
            id: create_modal_id,
            size: :sm,
            data: {collection_editor_create_modal: "true"}
          ) do |modal|
            modal.header { render_dialog_title }
            modal.body { render_create_body }
            modal.footer { render_create_footer }
          end
        end

        def render_dialog_title
          content_tag(
            :h2,
            create_modal_title,
            class: "text-lg font-semibold text-[var(--modal-title-color)] fp-text-balance",
            data: {collection_editor_modal_title: "true"}
          )
        end

        def render_create_body
          content_tag(:div, class: "flat-pack-collection-editor-create-fields", data: {collection_editor_create_fields: "true"}) do
            safe_join([
              content,
              content_tag(:p, "", class: "flat-pack-collection-editor-create-error", role: "alert", data: {collection_editor_create_error: "true"}, hidden: true)
            ])
          end
        end

        def render_create_footer
          safe_join([
            render(FlatPack::Button::Component.new(
              text: "Cancel",
              style: :secondary,
              type: "button",
              data: {action: "click->flat-pack--modal#close"}
            )),
            render(FlatPack::Button::Component.new(
              text: @create_label,
              style: :primary,
              type: "button",
              data: {collection_editor_create_submit: "true"}
            ))
          ])
        end

        def render_error
          return if @error.blank?

          content_tag(:p, @error, class: "flat-pack-collection-editor-error", role: "alert")
        end

        def sanitize_endpoint(url)
          FlatPack::AttributeSanitizer.sanitize_url(url)
        end

        def update_endpoint(url)
          sanitized = sanitize_endpoint(url)
          return if sanitized.blank? || !sanitized.include?(":id")

          sanitized
        end
      end
    end
  end
end
