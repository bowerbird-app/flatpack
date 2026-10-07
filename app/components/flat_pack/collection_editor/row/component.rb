# frozen_string_literal: true

module FlatPack
  module CollectionEditor
    module Row
      class Component < FlatPack::BaseComponent
        renders_one :entity, "FlatPack::CollectionEditor::Entity::Component"
        renders_many :fields
        renders_many :actions

        def initialize(
          form:,
          remove_label: nil,
          record_id: nil,
          persisted: nil,
          index_token: "NEW_RECORD",
          **system_arguments
        )
          super(**system_arguments)
          @form = form
          @remove_label = remove_label
          @record_id = record_id
          @persisted = persisted
          @index_token = index_token.to_s.presence || "NEW_RECORD"
        end

        def destroyed_row?
          object = @form.object
          object.respond_to?(:marked_for_destruction?) && object.marked_for_destruction?
        end

        def call
          content
          content_tag(:li, **row_attributes) do
            safe_join([
              hidden_id_field,
              hidden_destroy_field,
              render_handle,
              (entity if entity?),
              render_fields,
              render_actions
            ].compact)
          end
        end

        private

        def row_attributes
          data = {
            collection_editor_row: "true",
            persisted: persisted_record?.to_s,
            id: row_identifier
          }
          data[:orderable_unsaved] = "true" unless persisted_record?
          data[:collection_editor_destroyed] = "true" if destroyed_row?
          data.merge!(picker_data)

          merge_attributes(
            class: row_classes,
            role: "listitem",
            hidden: destroyed_row?,
            data: data
          )
        end

        def row_classes
          classes(
            "flat-pack-collection-editor-row",
            ("is-invalid" if invalid?)
          )
        end

        def picker_data
          return {} unless entity?

          {
            search_url: entity.search_url,
            search_param: entity.search_param,
            min_search_length: entity.min_search_length,
            create_url: entity.create_url,
            create_label: entity.create_label,
            empty_text: entity.empty_text,
            edit_url_template: entity.edit_url_template,
            items: entity.items_json
          }.compact
        end

        def hidden_id_field
          return unless persisted_record?

          @form.hidden_field(:id)
        end

        def hidden_destroy_field
          return unless persisted_record?

          @form.hidden_field(
            :_destroy,
            value: destroyed_row? ? "1" : "0",
            data: {collection_editor_destroy: "true"}
          )
        end

        def render_handle
          return unless orderable?

          button_tag(
            type: "button",
            class: "flat-pack-collection-editor-handle",
            aria: {label: reorder_label, keyshortcuts: "ArrowUp ArrowDown"},
            data: {collection_editor_handle: "true"}
          ) do
            render FlatPack::Shared::IconComponent.new(name: "bars-3", size: :sm)
          end
        end

        def render_fields
          return if fields.blank?

          safe_join(fields.map { |field|
            content_tag(:div, class: "flat-pack-collection-editor-fields") { field.to_s }
          })
        end

        def render_actions
          content_tag(:div, class: "flat-pack-collection-editor-actions") do
            safe_join([
              (safe_join(actions) if actions.any?),
              render_remove
            ].compact)
          end
        end

        def render_remove
          render FlatPack::Button::Component.new(
            type: "button",
            style: :ghost,
            size: :sm,
            icon: "trash",
            icon_only: true,
            aria: {label: remove_label},
            data: {
              collection_editor_remove: "true",
              action: "click->flat-pack--collection-editor#remove"
            }
          )
        end

        def orderable?
          flag = data_attributes[:orderable]
          flag = data_attributes["orderable"] if flag.nil?
          flag != false && flag != "false"
        end

        def persisted_record?
          return @persisted unless @persisted.nil?

          object = @form.object
          object.respond_to?(:persisted?) && object.persisted?
        end

        def row_identifier
          return @record_id.to_s if @record_id.present?
          return record_object_id.to_s if persisted_record? && record_object_id.present?

          @index_token
        end

        def record_object_id
          object = @form.object
          object.id if object.respond_to?(:id)
        end

        def summary_title
          return unless entity?

          entity.title
        end

        def reorder_label
          summary_title.present? ? "Reorder #{summary_title}" : "Reorder row"
        end

        def remove_label
          return @remove_label if @remove_label.present?

          summary_title.present? ? "Remove #{summary_title}" : "Remove row"
        end

        def invalid?
          object = @form.object
          object.respond_to?(:errors) && object.errors.any?
        end
      end
    end
  end
end
