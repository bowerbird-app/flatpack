# Modal Filter

## Purpose
Render a single Filter trigger that always opens a modal form, with all filter controls defined in one dedicated slot.

## When to use
Use this when filter controls should be hidden from inline layouts and shown only in a modal flow:
- Desktop: Filter trigger opens modal.
- Mobile: Filter trigger opens the same modal.
- Shared behavior: filter content renders only in `filter_body` and is never rendered inline.

## Class
- Primary: `FlatPack::ModalFilter::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `id` | String | - | yes | Stable id used to build modal id and modal form id. |
| `form_url` | String | - | yes | Form submission URL for modal flow. |
| `turbo_frame` | String | - | yes | Turbo Frame target for modal form submissions. |
| `form_method` | Symbol, String | `:get` | no | Form method used by modal form. |
| `active_count` | Integer | `0` | no | Count shown in an `:xs` primary badge when greater than zero. |
| `trigger_label` | String | `"Filter"` | no | Trigger base label text. |
| `button_size` | Symbol | `:sm` | no | Size passed to the Filter trigger button (`:sm`, `:md`, or `:lg`). |
| `modal_title` | String | `"Filters"` | no | Modal heading text. |
| `submit_label` | String | `"Apply"` | no | Submit button label. |
| `reset_label` | String | `"Reset"` | no | Reset link label. |
| `reset_url` | String, nil | `nil` | no | Optional reset URL rendered in modal actions. |
| `mobile_form_class` | String, nil | `nil` | no | Additional classes for modal form element. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer wrapper. |

## Slots
| name | type | description |
| --- | --- | --- |
| `filter_body` | slot | Required modal-only filter controls. Content renders exclusively inside modal body. |

## Variants
None.

## Example
```erb
<%= render FlatPack::ModalFilter::Component.new(
  id: "modal-filter-table-controls",
  form_url: demo_modal_filter_path,
  turbo_frame: "modal-filter-table-frame",
  active_count: @modal_filter_active_count,
  reset_url: demo_modal_filter_path,
  mobile_form_class: "space-y-3",
  button_size: :lg
) do |modal_filter| %>
  <% modal_filter.filter_body do %>
    <%= render FlatPack::Select::Component.new(
      name: "modal_status",
      value: @modal_filter_status,
      options: @table_filter_definitions.fetch("status").fetch(:values).map { |value_key, value_label| [value_label, value_key] },
      label: "Status"
    ) %>

    <%= render FlatPack::Select::Component.new(
      name: "modal_category",
      value: @modal_filter_category,
      options: @table_filter_definitions.fetch("category").fetch(:values).map { |value_key, value_label| [value_label, value_key] },
      label: "Category"
    ) %>

    <%= render FlatPack::Search::Component.new(
      name: "modal_q",
      value: @modal_filter_search_query,
      placeholder: "Search table rows...",
      max_width: :none,
      class: "w-full"
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Keep `trigger_label` text explicit (for example `Filter`) so intent is clear to screen reader users.
- Ensure controls in `filter_body` have visible labels or equivalent accessible names.
- Use descriptive `modal_title` text when multiple modal filters exist on one page.

## Dependencies
- `FlatPack::Modal::Component` for modal rendering.
- `FlatPack::Button::Component` for reset and submit actions.
- `FlatPack::Badge::Component` for count display.
