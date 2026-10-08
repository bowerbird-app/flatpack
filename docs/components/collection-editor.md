# Collection Editor

## Purpose
Edit an ordered collection of related records inside a normal Rails form. Each row shows one saved record and the fields that belong to the relationship. The row stays compact. Display many. Edit one.

## When to use
Use Collection Editor for collaborators, team members, related companies, locations, or any repeated join. The host owns the models, the search endpoint, and authorization. FlatPack owns the row chrome, the picker, add and remove, and the reorder gesture.

Each cell edits one value. The row is not a calculated spreadsheet. Do not use it to edit the saved record and the relationship in the same fields. Name and email belong to the person. Role belongs to the join.

## Class
- Primary: `FlatPack::CollectionEditor::Component`
- Related classes: `FlatPack::CollectionEditor::Row::Component`, `FlatPack::CollectionEditor::Entity::Component`

## Props
`FlatPack::CollectionEditor::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | no | Heading above the bordered list. |
| `add_label` | String | `"Row"` | no | Label on the full-width ghost row at the bottom of the table. The plus icon stays, so the default reads "+ Row". |
| `empty_text` | String | `"Nothing here yet"` | no | Copy shown when every row is gone. |
| `headers` | Array | `nil` | no | One desktop label per content cell. With an entity, that cell comes first, then each field. A row of only fields uses one header per field. The handle and the remove control stay unlabeled. Without headers the desktop grid still reserves two content columns. |
| `orderable` | Boolean | `false` | no | Shows a drag handle and mounts `flat-pack--list-orderable`. |
| `orderable_url` | String | `nil` | no | PATCH endpoint for a persisted row. Same contract as List. |
| `orderable_method` | String/Symbol | `:patch` | no | Request method for the reorder request. |
| `param_uuid_name` | String | `"id"` | no | Parameter name for the moved row id. |
| `param_target_position_name` | String | `"position"` | no | Parameter name for the 1-based destination. |
| `template_index` | String | `"NEW_RECORD"` | no | Placeholder swapped for a unique child index when a row is added. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the section. |

`FlatPack::CollectionEditor::Row::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `form` | FormBuilder | none | yes | Nested `fields_for` builder for the join record. |
| `remove_label` | String | `nil` | no | Accessible name for remove. Defaults to `Remove` plus the entity title. |
| `record_id` | String | `nil` | no | Id sent by the reorder request. Defaults to the join record id. |
| `persisted` | Boolean | `nil` | no | Forces the persisted or unsaved remove behavior. |
| `index_token` | String | `"NEW_RECORD"` | no | `data-id` used on an unsaved row so the template index can be replaced. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the row. |

`FlatPack::CollectionEditor::Entity::Component`:

| name | type | default | required | description |
|---|---|---|---|---|
| `form` | FormBuilder | none | yes | Same nested builder as the row. |
| `association_name` | Symbol/String | none | yes | Hidden field that receives the selected record id. |
| `title` | String | `nil` | no | Primary text for the selected record, such as the person name. |
| `description` | String | `nil` | no | Secondary text, such as the email. Search results can show it. The selected record does not. |
| `value` | String | `nil` | no | Selected id. Omit it to use the form object. |
| `label` | String | `"Record"` | no | Accessible name for the search field. The placeholder stays visible text. |
| `search_url` | String | `nil` | no | GET endpoint. Response shape matches Select remote search, with an optional description. |
| `search_param` | String | `"q"` | no | Query parameter name. |
| `min_search_length` | Integer | `1` | no | Characters required before results are shown. |
| `create_url` | String | `nil` | no | POST endpoint for a new record. Omit it to hide create. |
| `create_label` | String | `"Create"` | no | Submit label in the create modal. The menu item that opens the modal reads "+ New". |
| `search_placeholder` | String | `"Search"` | no | Search field placeholder. |
| `empty_text` | String | `"No matches"` | no | Copy when a query has no results. |
| `search_error_text` | String | `"Search failed"` | no | Copy when the search request fails. |
| `items` | Array | `nil` | no | Local results used when `search_url` is omitted. Each item is `{ id:, title:, description: }`. `value` and `label` are also accepted. |
| `edit_url_template` | String | `nil` | no | Accepted and not rendered. Put a record edit link in a row action when the host still needs one. |
| `edit_label` | String | `"Edit"` | no | Accepted and not rendered. |
| `change_label` | String | `"Change"` | no | Accepted and not rendered. The chip remove control drops the row. |
| `error` | String | `nil` | no | Association error under the summary. |
| `open` | Boolean | `false` | no | Starts with the picker open. A row with no title also starts open. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the entity cell. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `row` | `Row::Component` | no | One join row. Call `with_row` inside the component block. |
| `template` | slot | no | HTML cloned for a new row. Put one unsaved row here and use `template_index` in its `fields_for` child index. |
| `entity` | `Entity::Component` | no | Selected record, on the row. |
| `field` | slot | no | One relationship field. Each block is its own cell. Render a normal FlatPack input and pass `chrome: :cell`. |
| `action` | slot | no | Extra row actions, before remove. |
| `content` on the entity | slot | no | Fields posted to `create_url`. They render in the create modal. Give each input `data-create-field` and `form="collection-editor-unattached"` so the parent form does not submit them. Mark the input that should receive the search text with `data-fill-from-query`. |

## Variants
- Orderable rows use the List reorder controller. Without `orderable: true` the handle is hidden.
- A persisted row sets `_destroy` to `1` and hides. An unsaved row is removed from the page.
- Search uses `search_url` when it is present, otherwise `items`.

## Example
```erb
<%= form_with model: @project do |form| %>
  <%= render FlatPack::CollectionEditor::Component.new(
    title: "Collaborators",
    empty_text: "No collaborators yet",
    headers: ["Person", "Role"],
    orderable: true,
    orderable_url: reorder_project_people_path(@project),
    param_uuid_name: "moving_recording_id",
    param_target_position_name: "target_position"
  ) do |editor| %>
    <% @project.project_people.each do |membership| %>
      <% form.fields_for :project_people, membership, child_index: membership.id do |row_form| %>
        <% editor.with_row(form: row_form) do |row| %>
          <% row.with_entity(
            form: row_form,
            association_name: :person_id,
            title: membership.person.name,
            description: membership.person.email,
            search_url: search_people_path,
            create_url: people_path,
            search_placeholder: "Search people"
          ) do %>
            <%= render FlatPack::TextInput::Component.new(name: "name", label: "Name", form: "collection-editor-unattached", data: { create_field: "name", fill_from_query: "true" }) %>
            <%= render FlatPack::EmailInput::Component.new(name: "email", label: "Email", form: "collection-editor-unattached", data: { create_field: "email" }) %>
          <% end %>
          <% row.with_field do %>
            <%= render FlatPack::Select::Component.new(
              name: row_form.field_name(:role),
              label: "Role",
              options: ["Designer", "Photographer", "Producer"],
              value: row_form.object.role,
              error: row_form.object.errors.full_messages_for(:role).to_sentence.presence,
              chrome: :cell
            ) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>

    <% editor.with_template do %>
      <% form.fields_for :project_people, ProjectPerson.new, child_index: "NEW_RECORD" do |row_form| %>
        <%= render FlatPack::CollectionEditor::Row::Component.new(form: row_form, index_token: "NEW_RECORD") do |row| %>
          <% row.with_entity(
            form: row_form,
            association_name: :person_id,
            search_url: search_people_path,
            create_url: people_path,
            search_placeholder: "Search people"
          ) do %>
            <%= render FlatPack::TextInput::Component.new(name: "name", label: "Name", form: "collection-editor-unattached", data: { create_field: "name", fill_from_query: "true" }) %>
            <%= render FlatPack::EmailInput::Component.new(name: "email", label: "Email", form: "collection-editor-unattached", data: { create_field: "email" }) %>
          <% end %>
          <% row.with_field do %>
            <%= render FlatPack::Select::Component.new(
              name: row_form.field_name(:role),
              label: "Role",
              options: ["Designer", "Photographer", "Producer"],
              chrome: :cell
            ) %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

The heading sits outside the bordered list. The list, the column headers, the empty state, and the add row stay in that card. The add row is a full-width ghost button at the bottom of the table. The plus icon stays, and the default label is "Row", so it reads "+ Row".

The template repeats the entity picker and the role field. The add button clones it and replaces `NEW_RECORD` inside `name`, `id`, `for`, `data-id`, `data-results-id`, `data-create-modal-id`, and the aria attributes that point at those ids. Text in the row is left as written. Rails 8 strong parameters keep nested attribute keys that are integers, so the index is numeric rather than a prefixed token. Rails accepts that index in `project_people_attributes`.

Selecting a person writes `person_id` and shows the name as an info chip. The email stays off the chip. The chip remove control drops the row. A saved row sets `_destroy`. An unsaved row leaves the document. The person record stays. Role stays on `ProjectPerson` until that row is removed.

Remove hides a saved row and submits `_destroy=1`. The person record stays. An unsaved row is dropped from the document and is not submitted.

Search `GET search_url?q=` returns `{ "items": [{ "id": "4", "title": "Alice Chen", "description": "alice@example.com" }] }`. `value` and `label` are accepted too. Enter selects the highlighted result, or the only result. Several results stay in the menu and do not create a record. No results shows "+ New" at the bottom of the menu. "+ New" copies the query into inputs marked `data-fill-from-query` and opens a modal. Cancel, Escape, and the backdrop close that modal and leave the row on the search field. A failed request shows `search_error_text` and leaves the join id empty. Create `POST create_url` with the `data-create-field` inputs and the query. A second submit while that request is in flight is ignored. Success is `{ "ok": true, "item": { "id", "title", "description" } }`. The modal closes and the row shows the info chip. Failure is `{ "ok": false, "errors": ["Email can't be blank"] }` with status 422. The modal stays open and the join row does not receive an id.

Reorder uses the existing List orderable request. FlatPack does not add a position column. A persisted row sends `moving_recording_id` and `target_position` when those parameter names are set. That position counts saved rows only, so an unsaved row on screen does not shift the saved destination. `list:reordered` still reports the visual position. The host persists the saved move with Recording Studio Orderable, or with whatever ordering API already owns the collection. The dummy app translates this payload through `Ordering::ReorderService`. An unsaved row is marked `data-orderable-unsaved="true"`, so its own move stays in the form and no request is sent. Submit the parent form in DOM order and assign order on the host when the join records are created.

The dummy reorder route also has the project id in the path. The row id therefore uses `moving_recording_id`, not `id`, so the path id and the row id stay distinct. Use the same split when a host route already consumes `id`.

`list:reordered` fires after the DOM move. The collection editor writes that move into a polite status. `list:saved` fires when the endpoint returns `{ "ok": true }`. `list:error` fires when the save fails.

Rendered field errors stay on the FlatPack input passed in the field slot. The row also takes the `is-invalid` class when the join object has errors, and the entity `error` argument prints the association message. A failed parent save re-renders the nested attributes, including rows added in the browser, as long as the controller assigns the invalid parent back to the form.

Desktop rows are a grid. `--collection-editor-border-color` draws the lines. The handle, the person, each relationship field, and remove are separate cells. The selected record is a removable info chip. Search results open in a menu under the field, using the popover surface, border, radius, and shadow. A query with no matches shows "+ New" at the bottom of that menu when `create_url` is set. "+ New" opens a small modal titled from the entity label, such as "New Person". The dialog is portaled to the page so the card does not clip it. The search cell stays one line. Pass `chrome: :cell` on Text input, Select, Search input, and the other controls that share that box. The control drops its border, radius, and background. Select keeps `flat-pack-select-wrapper` and also uses `flat-pack-input-wrapper`, so the control fills the cell. A single-line cell keeps horizontal `--form-control-padding` and drops the vertical field padding, so the row is the 44px remove control and the value lines up with the trash icon. The person chip sits in that same row. The role and the remove control stay centered. An error under the value makes that row taller. Focus and an invalid value draw an inset ring on the cell. The person search uses that same cell treatment. Name and email inside Create stay bordered. Below 40rem the person, each field, and the actions stack. Column headers hide. Field labels show again. The page does not scroll sideways.

A row can skip the entity and hold only fields. The dummy Text fields section does that with three single-line text inputs, each passed `chrome: :cell`. There is no person picker and no dropdown. Those rows are unsaved, so a drag stays on the page.

`headers` lines up with those content cells. A second `with_field` needs a third header. The section sets `--collection-editor-columns` from that count so the header and the rows share one grid. That property is runtime layout, not a theme token. `--collection-editor-row-padding` pads the empty state. Cell text keeps horizontal `--form-control-padding`.

Tokens alias the surface, list, and primary tokens. Override them on a parent to recolor this component without a new theme.

```css
.collaborators {
  --collection-editor-title-color: var(--color-primary);
  --collection-editor-description-color: var(--surface-muted-content-color);
  --collection-editor-row-hover-background-color: var(--list-item-hover-background-color);
  --collection-editor-drop-indicator-color: var(--color-primary);
}
```

Dragged rows and the landing slot still use the List orderable styles. The landing slot also draws `--collection-editor-drop-indicator-color`.

## Accessibility
- The handle is a button named `Reorder` plus the record title. Arrow Up and Arrow Down move the row when ordering is on.
- Remove is a ghost icon button with a trash icon, named `Remove` plus the record title.
- Search is a combobox named by `label`. Results are a listbox. Each option exposes the title and the description as text. Arrow keys set `aria-activedescendant` on the search field.
- A polite status announces the row title and visual position after a move.
- The association id and `_destroy` are hidden inputs.
- Adding a row focuses its search field. Removing a row focuses the add button.
- A blank row keeps the picker open so keyboard users can search before the parent form is submitted.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers `flat-pack--collection-editor` and, when `orderable: true`, `flat-pack--list-orderable`.
- A host search endpoint and, if create is enabled, a host create endpoint.
- Recording Studio Orderable, or the host's existing reorder endpoint, for persisted order. FlatPack only sends the List reorder request.
