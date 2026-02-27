# Chart Component

## Purpose
Render ApexCharts-based visualizations with FlatPack defaults and optional card framing.

## When to use
Use this for dashboard and analytics charts when data is available in ApexCharts-compatible series format.

## Class
- `FlatPack::Chart::Component`

## Props
| Prop | Type | Default | Description |
| --- | --- | --- | --- |
| `series` | Array or Hash | required | Chart series payload passed to ApexCharts. |
| `type` | Symbol | `:line` | One of `:line`, `:bar`, `:area`, `:donut`, `:pie`, `:radar`. |
| `options` | Hash | `{}` | ApexCharts options deep-merged over component defaults. |
| `height` | Integer | `280` | Chart height in pixels; must be positive. |
| `card` | Boolean | `true` | Wraps chart in `FlatPack::Card::Component` with header/body/footer layout. |
| `title` | String, nil | `nil` | Optional title shown in card header. |
| `subtitle` | String, nil | `nil` | Optional subtitle shown under title. |
| `**system_arguments` | Hash | `{}` | Forwarded HTML attributes for outer container in chart-only mode. |

## Slots
| Slot | Description |
| --- | --- |
| `actions` | Header action area (for buttons, filters, menus) when `card: true`. |
| `footer` | Card footer content when `card: true`. |

## Variants
- Chart type variant via `type`
- Framed (`card: true`) and inline (`card: false`) rendering
- Axis defaults for line/bar/area/radar and non-axis defaults for donut/pie

## Example
```erb
<%= render FlatPack::Chart::Component.new(
  series: [
    { name: "Revenue", data: [44, 55, 57, 56, 61, 58, 63] },
    { name: "Expenses", data: [35, 41, 36, 26, 45, 48, 52] }
  ],
  type: :area,
  title: "Financial Overview",
  subtitle: "Last 7 months"
) do |chart| %>
  <% chart.with_actions do %>
    <%= render FlatPack::Button::Component.new(text: "Export", size: :sm, style: :ghost) %>
  <% end %>
<% end %>
```

## Accessibility
- Provide meaningful `title`/`subtitle` or nearby text that describes chart intent.
- For critical data, provide a tabular or textual alternative outside the chart canvas.
- Avoid relying only on color to communicate state across series.

## Dependencies
- Stimulus controller: `app/javascript/flat_pack/controllers/chart_controller.js` (`flat-pack--chart`).
- ApexCharts import map pin (`import "apexcharts"` via dynamic import in controller).
- `FlatPack::Card::Component` when `card: true`.
