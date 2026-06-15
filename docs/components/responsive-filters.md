# Responsive Filters

## Purpose
Render one reusable filter definition as desktop inline controls and a mobile modal flow, with a mobile trigger label that can include an active-filter count badge.

## When to use
Use this when a chart or table should keep one result surface while filter controls switch presentation by viewport:
- Desktop: inline form controls with optional auto-submit.
- Mobile: single Filter trigger that opens a modal and submits on Apply.

For chart default filtering, prefer `FlatPack::Chart::DefaultFilterComponent` with `responsive: true` so you can opt into responsive behavior directly from that component.

## Class
- Primary: `FlatPack::ResponsiveFilters::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `id` | String | - | yes | Stable id used to build the modal id and mobile form id. |
| `form_url` | String | - | yes | Form submission URL for both desktop and mobile flows. |
| `turbo_frame` | String | - | yes | Turbo Frame target for filter submissions. |
| `form_method` | Symbol, String | `:get` | no | Form method used by desktop and mobile forms. |
| `active_count` | Integer | `0` | no | Count shown in a primary `:xs` badge on the mobile trigger when greater than zero. |
| `trigger_label` | String | `"Filter"` | no | Base text for the mobile trigger button. |
| `modal_title` | String | `"Filters"` | no | Modal heading text. |
| `submit_label` | String | `"Apply"` | no | Mobile submit button label. |
| `reset_label` | String | `"Reset"` | no | Mobile reset link label. |
| `reset_url` | String, nil | `nil` | no | Optional reset link URL rendered in mobile actions. |
| `auto_submit_desktop` | Boolean | `true` | no | Enables debounced desktop auto-submit behavior. |
| `auto_submit_delay` | Integer | `250` | no | Delay passed to `flat-pack--auto-submit` on desktop form. |
| `desktop_form_class` | String, nil | `nil` | no | Additional classes for desktop form element. |
| `mobile_form_class` | String, nil | `nil` | no | Additional classes for mobile modal form element. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the outer wrapper. |

## Slots
| name | type | description |
| --- | --- | --- |
| `fields` | slot | Shared filter controls for desktop form; also used by mobile when `mobile_fields` is not provided. |
| `mobile_fields` | slot | Optional mobile-specific control layout (for tighter stacks and widths). |

## Example
```erb
<%= render FlatPack::ResponsiveFilters::Component.new(
  id: "basic-table-generic-filters",
  form_url: demo_tables_basic_path,
  turbo_frame: "basic-table-generic-filter-frame",
  active_count: @table_filter_active_count,
  reset_url: demo_tables_basic_path,
  desktop_form_class: "mb-4 flex flex-wrap items-end gap-3",
  mobile_form_class: "space-y-3"
) do |filters| %>
  <% filters.fields do %>
    <%= render FlatPack::Select::Component.new(
      name: "status",
      value: @table_filter_status,
      options: @table_filter_definitions.fetch("status").fetch(:values).map { |value_key, value_label| [value_label, value_key] },
      label: "Status"
    ) %>

    <%= render FlatPack::Select::Component.new(
      name: "category",
      value: @table_filter_category,
      options: @table_filter_definitions.fetch("category").fetch(:values).map { |value_key, value_label| [value_label, value_key] },
      label: "Category"
    ) %>

    <%= render FlatPack::Search::Component.new(
      name: "q",
      value: @table_search_query,
      placeholder: "Search table rows...",
      max_width: :none,
      class: "w-56"
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Ensure each filter control has a visible label or equivalent accessible name.
- Keep modal titles and action labels specific to filter intent.
- Avoid icon-only trigger text for filter buttons when count context matters.

## Dependencies
- `FlatPack::Modal::Component` for mobile overlay behavior.
- `flat-pack--auto-submit` Stimulus controller when desktop auto-submit is enabled.
