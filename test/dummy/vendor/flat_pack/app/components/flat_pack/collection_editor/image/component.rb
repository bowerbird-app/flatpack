# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    module Image
      # Identity cell for a join to a library image. The thumbnail opens the
      # library record when update_url is set. An empty cell opens the library.
      class Component < FlatPack::BaseComponent
        attr_reader :search_url, :search_param, :min_search_length, :create_url,
          :create_label, :empty_text, :edit_url_template, :edit_label,
          :update_url, :update_label, :title, :thumbnail_url

        def initialize(
          form:,
          association_name:,
          title: nil,
          thumbnail_url: nil,
          alt: nil,
          value: nil,
          label: nil,
          search_url: nil,
          search_param: "q",
          min_search_length: 0,
          create_url: nil,
          create_label: "Create",
          choose_label: nil,
          empty_text: "No images",
          search_error_text: "Search failed",
          items: nil,
          edit_url_template: nil,
          edit_label: nil,
          update_url: nil,
          update_label: nil,
          error: nil,
          **system_arguments
        )
          super(**system_arguments)
          @form = form
          @association_name = association_name
          @title = title.to_s.presence
          @thumbnail_url = thumbnail_url.to_s.presence
          @alt = alt.to_s.presence
          @value = value
          @label = label.to_s.presence || "Image"
          @search_url = sanitize_endpoint(search_url)
          @search_param = search_param.to_s.presence || "q"
          @min_search_length = min_search_length.to_i
          @create_url = sanitize_endpoint(create_url)
          @create_label = create_label.to_s.presence || "Create"
          @choose_label = choose_label.to_s.presence || FlatPack::Copy.t("collection_editor.choose_image")
          @empty_text = empty_text.to_s.presence || "No images"
          @search_error_text = search_error_text.to_s.presence || "Search failed"
          @items = items
          @edit_url_template = sanitize_endpoint(edit_url_template)
          @edit_label = edit_label.to_s.presence || FlatPack::Copy.t("common.edit")
          @update_url = update_endpoint(update_url)
          @update_label = update_label.to_s.presence || FlatPack::Copy.t("common.save")
          @error = error.to_s.presence
          @field_key = form.field_id(association_name)
        end

        def items_json
          return if @items.nil?

          Array(@items).to_json
        end

        def call
          content_tag(:div, **image_attributes) do
            safe_join([
              association_field,
              render_summary,
              render_library_modal,
              render_record_modal,
              render_error
            ].compact)
          end
        end

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

        def image_attributes
          data = {collection_editor_image: "true", library_modal_id: library_modal_id}
          data[:create_modal_id] = record_modal_id if dialog?

          merge_attributes(
            class: "flat-pack-collection-editor-entity flat-pack-collection-editor-image",
            data: data
          )
        end

        def association_field
          options = {data: {collection_editor_association: "true"}}
          options[:value] = @value unless @value.nil?
          @form.hidden_field(@association_name, options)
        end

        def render_summary
          content_tag(:div, class: "flat-pack-collection-editor-summary", data: {collection_editor_summary: "true"}) do
            safe_join([
              render_choose,
              content_tag(:span, @title.to_s, class: "flat-pack-collection-editor-sr", data: {collection_editor_title: "true"})
            ])
          end
        end

        def render_choose
          button_tag(
            type: "button",
            class: "flat-pack-collection-editor-image-choose",
            aria: {label: choose_accessible_name},
            data: {
              collection_editor_image_choose: "true",
              action: "click->flat-pack--collection-editor#openImage"
            }
          ) do
            safe_join([
              content_tag(:span, render_placeholder_icon, class: "flat-pack-collection-editor-image-placeholder", data: {collection_editor_image_placeholder: "true"}, hidden: thumbnail?),
              tag.img(
                src: @thumbnail_url,
                alt: "",
                hidden: !thumbnail?,
                data: {collection_editor_image_preview: "true"}
              )
            ])
          end
        end

        def render_placeholder_icon
          render FlatPack::Shared::IconComponent.new(name: "image", size: :sm)
        end

        def choose_accessible_name
          return "#{@edit_label} #{@title}" if editable? && @title.present?
          return @title if @title.present?

          @choose_label
        end

        def thumbnail?
          @thumbnail_url.present?
        end

        def render_library_modal
          render FlatPack::Modal::Component.new(
            id: library_modal_id,
            size: :lg,
            data: {collection_editor_library_modal: "true"}
          ) do |modal|
            modal.header { content_tag(:h2, @choose_label, class: "text-lg font-semibold text-[var(--modal-title-color)] fp-text-balance") }
            modal.body { render_library_body }
          end
        end

        def render_library_body
          content_tag(:div, class: "flex flex-col gap-4") do
            safe_join([
              content_tag(:div, class: "flex flex-col gap-3 sm:flex-row sm:items-center") do
                safe_join([
                  content_tag(:div, class: "min-w-0 flex-1") do
                    safe_join([
                      content_tag(:label, @choose_label, for: library_search_id, class: "flat-pack-collection-editor-sr"),
                      tag.input(
                        id: library_search_id,
                        type: "search",
                        form: "collection-editor-unattached",
                        class: "flat-pack-collection-editor-library-search",
                        placeholder: @choose_label,
                        autocomplete: "off",
                        spellcheck: "false",
                        data: {
                          collection_editor_library_search: "true",
                          action: "input->flat-pack--collection-editor#searchLibrary keydown->flat-pack--collection-editor#searchLibraryKeydown"
                        }
                      )
                    ])
                  end,
                  (render_new_image if creatable?)
                ].compact)
              end,
              content_tag(:p, @empty_text, class: "flat-pack-collection-editor-no-results", data: {collection_editor_library_empty: "true"}, hidden: true),
              content_tag(:p, @search_error_text, class: "flat-pack-collection-editor-search-error", role: "alert", data: {collection_editor_library_error: "true"}, hidden: true),
              content_tag(:div, "", class: "flat-pack-collection-editor-library", data: {collection_editor_library: "true"})
            ])
          end
        end

        def render_new_image
          render FlatPack::Button::Component.new(
            text: "+ New",
            style: :secondary,
            type: "button",
            data: {action: "click->flat-pack--collection-editor#createFromLibrary"}
          )
        end

        def creatable?
          content? && @create_url.present?
        end

        def render_record_modal
          return unless dialog?

          render FlatPack::Modal::Component.new(
            id: record_modal_id,
            size: :sm,
            data: {collection_editor_create_modal: "true"}
          ) do |modal|
            modal.header { render_dialog_title }
            modal.body { render_record_body }
            modal.footer { render_record_footer }
          end
        end

        def render_dialog_title
          content_tag(
            :h2,
            create_title,
            class: "text-lg font-semibold text-[var(--modal-title-color)] fp-text-balance",
            data: {collection_editor_modal_title: "true"}
          )
        end

        def render_record_body
          content_tag(:div, class: "flat-pack-collection-editor-create-fields", data: {collection_editor_create_fields: "true"}) do
            safe_join([
              content,
              content_tag(:p, "", class: "flat-pack-collection-editor-create-error", role: "alert", data: {collection_editor_create_error: "true"}, hidden: true)
            ])
          end
        end

        def render_record_footer
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

        def library_modal_id
          "fp-collection-editor-#{@field_key}-library"
        end

        def library_search_id
          "fp-collection-editor-#{@field_key}-library-search"
        end

        def record_modal_id
          "fp-collection-editor-#{@field_key}-create"
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
