# frozen_string_literal: true

require "test_helper"

module FlatPack
  module CollectionEditor
    class Record
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :id
      attribute :person_id
      attribute :role
      attribute :name

      def persisted?
        id.present?
      end
    end

    class ComponentTest < ViewComponent::TestCase
      def test_renders_rows_entity_summary_and_nested_field_names
        membership = Record.new(id: 12, person_id: 4, role: "Designer", name: "Alice Chen")
        row_form = builder("project[project_people_attributes][12]", membership)

        render_inline(Component.new(title: "Collaborators", add_label: "Add collaborator", headers: ["Person", "Role"], orderable: true, orderable_url: "/reorder", param_uuid_name: "moving_recording_id", param_target_position_name: "target_position")) do |editor|
          editor.with_row(form: row_form) do |row|
            row.with_entity(
              form: row_form,
              association_name: :person_id,
              title: "Alice Chen",
              description: "alice@example.com",
              label: "Person",
              search_url: "/people",
              search_placeholder: "Search people",
              edit_url_template: "/people/:id/edit",
              edit_label: "Edit person"
            )
            row.with_field { row_form.text_field(:role) }
          end
        end

        assert_selector "section.flat-pack-collection-editor > h2", text: "Collaborators"
        assert_selector ".flat-pack-collection-editor-card .flat-pack-collection-editor-add button[data-fp-style='ghost']", text: "Add collaborator"
        assert_selector ".flat-pack-collection-editor-card [data-flat-pack--collection-editor-target='list']"
        assert_no_selector ".flat-pack-collection-editor-card h2"
        assert_no_selector "section.flat-pack-collection-editor > .flat-pack-collection-editor-add"
        assert_selector ".flat-pack-collection-editor-header", text: "Person"
        assert_selector ".flat-pack-collection-editor-header", text: "Role"
        assert_selector "[data-collection-editor-title]", text: "Alice Chen"
        assert_selector ".flat-pack-collection-editor-summary [data-controller='flat-pack--chip']", text: "Alice Chen"
        assert_includes rendered_content, "bg-[var(--color-secondary)]"
        assert_selector "[data-collection-editor-chip-remove][aria-label='Remove Alice Chen']"
        assert_no_selector ".flat-pack-collection-editor-edit"
        assert_no_selector ".flat-pack-collection-editor-change"
        assert_no_selector ".flat-pack-collection-editor-description", text: "alice@example.com"
        assert_selector "input[name='project[project_people_attributes][12][person_id]'][value='4']", visible: :all
        assert_selector "input[name='project[project_people_attributes][12][id]'][value='12']", visible: :all
        assert_selector "input[name='project[project_people_attributes][12][_destroy]'][value='0']", visible: :all
        assert_selector "input[name='project[project_people_attributes][12][role]']"
        assert_selector "[data-controller='flat-pack--list-orderable']"
        assert_selector "[data-flat-pack--list-orderable-handle-selector-value='[data-collection-editor-handle]']"
        assert_selector "[data-flat-pack--list-orderable-param-uuid-name-value='moving_recording_id']"
        assert_selector "[data-flat-pack--list-orderable-param-target-position-name-value='target_position']"
        assert_selector "button[aria-label='Reorder Alice Chen']"
        assert_selector "button[aria-label='Remove Alice Chen'][data-fp-style='ghost']"
        assert_selector "button[aria-label='Remove Alice Chen'] [data-flat-pack--icon-name-value='trash']"
        assert_no_selector "button[aria-label='Remove Alice Chen'][data-fp-style='danger']"
        assert_selector "[role='combobox'][aria-controls]", visible: :all
        assert_no_selector "[data-collection-editor-create-modal]", visible: :all
        assert_selector "label.flat-pack-collection-editor-sr", text: "Person", visible: :all
        assert_selector "[data-collection-editor-search-error]", text: "Search failed", visible: :all
        assert_selector "[data-flat-pack--collection-editor-target='status'][aria-live='polite']", visible: :all
        assert_no_selector ".flat-pack-collection-editor-empty"
        assert_no_selector "[data-collection-editor-edit]"
      end

      def test_update_url_turns_the_chip_name_into_an_edit_button
        membership = Record.new(id: 12, person_id: 4, role: "Designer", name: "Alice Chen")
        row_form = builder("project[project_people_attributes][12]", membership)
        view = vc_test_controller.view_context

        render_inline(Component.new) do |editor|
          editor.with_row(form: row_form) do |row|
            row.with_entity(
              form: row_form,
              association_name: :person_id,
              title: "Alice Chen",
              label: "Person",
              create_url: "/people",
              update_url: "/people/:id",
              edit_label: "Edit",
              update_label: "Save"
            ) do
              view.tag.input(type: "text", data: {create_field: "name"}, form: "collection-editor-unattached")
            end
          end
        end

        assert_selector ".flat-pack-collection-editor-chip > button.flat-pack-collection-editor-name[data-collection-editor-edit][aria-label='Edit Alice Chen']", text: "Alice Chen"
        assert_selector ".flat-pack-collection-editor-chip > [data-collection-editor-chip-remove][aria-label='Remove Alice Chen']"
        assert_selector "[data-update-url='/people/:id']"
        assert_selector "[data-edit-title='Edit Person']"
        assert_selector "[data-create-title='New Person']"
        assert_selector "[data-update-label='Save']"
        assert_selector "[data-collection-editor-modal-title]", text: "New Person"
        assert_no_selector "a.flat-pack-collection-editor-name"
      end

      def test_update_url_without_an_id_token_is_ignored
        membership = Record.new(id: 12, person_id: 4, name: "Alice Chen")
        row_form = builder("project[project_people_attributes][12]", membership)
        view = vc_test_controller.view_context

        render_inline(Component.new) do |editor|
          editor.with_row(form: row_form) do |row|
            row.with_entity(
              form: row_form,
              association_name: :person_id,
              title: "Alice Chen",
              update_url: "/people",
              create_url: "/people"
            ) do
              view.tag.input(type: "text", data: {create_field: "name"}, form: "collection-editor-unattached")
            end
          end
        end

        assert_selector "[data-collection-editor-title]", text: "Alice Chen"
        assert_no_selector "[data-collection-editor-edit]"
        assert_no_selector "[data-update-url]"
      end

      def test_empty_state_and_new_row_template_use_a_stable_child_index
        membership = Record.new(role: "")
        row_form = builder("project[project_people_attributes][NEW_RECORD]", membership)
        view = vc_test_controller.view_context

        render_inline(Component.new(empty_text: "No collaborators yet", template_index: "NEW_RECORD")) do |editor|
          row = Row::Component.new(form: row_form, index_token: "NEW_RECORD")
          row.with_entity(
            form: row_form,
            association_name: :person_id,
            search_placeholder: "Search people",
            create_url: "/people",
            items: [{id: 9, title: "Priya Shah", description: "priya@example.com"}]
          ) do
            view.tag.input(type: "text", data: {create_field: "name", fill_from_query: "true"}, form: "collection-editor-unattached")
          end
          row.with_field { row_form.text_field(:role) }
          editor.with_template { view.render(row) }
        end

        assert_text "No collaborators yet"
        assert_selector "template[data-flat-pack--collection-editor-target='template']", visible: :all
        assert_selector ".flat-pack-collection-editor-card [data-flat-pack--collection-editor-target='addButton']", text: "Row"
        assert_selector "[data-flat-pack--collection-editor-target='list']", visible: :all
        assert_selector "[data-flat-pack--collection-editor-target='empty']", text: "No collaborators yet", visible: :all
        html = rendered_content
        assert_includes html, "project[project_people_attributes][NEW_RECORD][person_id]"
        assert_includes html, "project[project_people_attributes][NEW_RECORD][role]"
        assert_includes html, "data-orderable-unsaved=\"true\""
        refute_includes html, "name=\"project[project_people_attributes][NEW_RECORD][_destroy]\""
        assert_includes html, "data-items="
        assert_includes html, "Priya Shah"
        assert_includes html, 'data-controller="flat-pack--modal"'
        assert_includes html, 'data-collection-editor-create-modal="true"'
        assert_includes html, 'data-collection-editor-create-submit="true"'
        assert_includes html, 'data-create-modal-id="fp-collection-editor-'
        assert_includes html, "NEW_RECORD"
        assert_includes html, "-create"
        assert_includes html, "New Record"
        assert_includes html, "max-w-sm"
        assert_includes html, 'role="dialog"'
        assert_includes html, ">Cancel</span>"
      end

      def test_invalid_row_keeps_the_compact_error_treatment
        membership = Record.new(id: 3, person_id: nil, role: "")
        membership.errors.add(:role, "can't be blank")
        membership.errors.add(:person, "must exist")
        row_form = builder("project[project_people_attributes][3]", membership)

        render_inline(Component.new) do |editor|
          editor.with_row(form: row_form) do |row|
            row.with_entity(
              form: row_form,
              association_name: :person_id,
              title: "Untitled",
              error: "Person must exist"
            )
            row.with_field { row_form.text_field(:role) }
          end
        end

        assert_selector "li.is-invalid"
        assert_selector ".flat-pack-collection-editor-error", text: "Person must exist"
        assert_selector "input[name='project[project_people_attributes][3][role]']"
      end

      def test_styles_use_collection_editor_tokens
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        variables = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

        assert_includes css, "var(--collection-editor-title-color)"
        assert_includes css, "var(--collection-editor-description-color)"
        assert_includes css, "var(--collection-editor-drop-indicator-color)"
        assert_includes css, "@media (min-width: 40rem)"
        assert_includes css, "grid-template-columns: auto minmax(0, 1fr) auto"
        assert_includes css, "@media (max-width: 39.999rem)"
        assert_includes css, ".flat-pack-collection-editor-actions {\n  grid-column: 3;\n  grid-row: 1;"
        assert_includes css, "border-inline-start: 0;"
        assert_includes css, ".flat-pack-collection-editor-row:not(:has(.flat-pack-collection-editor-entity)) > .flat-pack-collection-editor-fields:first-of-type"
        assert_includes css, ".flat-pack-collection-editor-row[hidden]"
        assert_includes css, "--collection-editor-columns"
        assert_includes css, "grid-template-columns: subgrid"
        assert_includes css, "border-inline-end: 1px solid var(--collection-editor-border-color)"
        assert_includes css, "inset 0 0 0 2px var(--color-ring)"
        assert_includes css, "inset 0 0 0 2px var(--color-error)"
        assert_includes css, ".flat-pack-collection-editor-name::before"
        assert_includes css, "inset: -1px;"
        assert_includes css, ".flat-pack-collection-editor-chip [data-collection-editor-chip-remove]"
        assert_includes css, ".flat-pack-collection-editor-fields :is(input, select, textarea, .flat-pack-select-trigger)"
        assert_includes css, "padding-block: 0"
        assert_includes css, ".flat-pack-modal__body .flat-pack-collection-editor-create-fields"
        refute_includes css, "justify-content: center"
        assert_includes variables, "--collection-editor-row-hover-background-color: var(--list-item-hover-background-color);"
      end

      def test_each_field_is_its_own_cell_and_headers_line_up
        membership = Record.new(id: 12, person_id: 4, role: "Designer", name: "Alice Chen")
        row_form = builder("project[project_people_attributes][12]", membership)

        render_inline(Component.new(headers: ["Person", "Role", "Note"], orderable: true, style: "color: red")) do |editor|
          editor.with_row(form: row_form) do |row|
            row.with_entity(form: row_form, association_name: :person_id, title: "Alice Chen")
            row.with_field { row_form.text_field(:role) }
            row.with_field { row_form.text_field(:name) }
          end
        end

        assert_selector ".flat-pack-collection-editor-fields", count: 2
        header = page.find(".flat-pack-collection-editor-header", visible: :all)
        assert_equal ["", "Person", "Role", "Note", ""], header.all("span", visible: :all).map { |span| span.text }
        assert_includes page.native.to_html, "color: red; --collection-editor-columns: auto minmax(0, 1.4fr) minmax(8rem, 1fr) minmax(8rem, 1fr) auto"
      end

      def test_headers_omit_the_handle_gutter_when_the_list_is_not_orderable
        membership = Record.new(id: 12, person_id: 4, role: "Designer", name: "Alice Chen")
        row_form = builder("project[project_people_attributes][12]", membership)

        render_inline(Component.new(headers: ["Person", "Role"])) do |editor|
          editor.with_row(form: row_form, data: {orderable: false}) do |row|
            row.with_entity(form: row_form, association_name: :person_id, title: "Alice Chen")
            row.with_field { row_form.text_field(:role) }
          end
        end

        header = page.find(".flat-pack-collection-editor-header", visible: :all)
        assert_equal ["Person", "Role", ""], header.all("span", visible: :all).map { |span| span.text }
        assert_no_selector ".flat-pack-collection-editor-handle"
        assert_includes page.native.to_html, "--collection-editor-columns: minmax(0, 1.4fr) minmax(8rem, 1fr) auto"
      end

      private

      def builder(object_name, object)
        ActionView::Helpers::FormBuilder.new(object_name, object, vc_test_controller.view_context, {})
      end
    end
  end
end
