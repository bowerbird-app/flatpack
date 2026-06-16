# Chart

## Purpose
Render ApexCharts-based visualizations with FlatPack defaults and optional card framing.

## When to use
Use this for dashboard and analytics charts when data is available in ApexCharts-compatible series format.
Use `FlatPack::ChartButtons::Component` as a sibling when you need reusable Turbo Frame filter controls outside the chart card header.
Use `FlatPack::Chart::DefaultFilterComponent` for date-range + optional status filtering, and enable `minimized: true` when you want desktop inline filters plus a mobile modal trigger.

## Class
- `FlatPack::Chart::Component`
- `FlatPack::Chart::DefaultFilterComponent`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `series` | Array or Hash | — | yes | Chart series payload passed to ApexCharts. |
| `type` | Symbol | `:line` | no | One of `:line`, `:column`, `:bar`, `:area`, `:donut`, `:pie`, `:radar`, `:funnel`, `:gauge`. Use `:column` for vertical bars, `:bar` for horizontal bars, `:funnel` for funnel stages, and `:gauge` for radial gauge-style KPI displays. |
| `options` | Hash | `{}` | no | ApexCharts options deep-merged over component defaults. |
| `height` | Integer | `280` | no | Chart height in pixels; must be positive. |
| `card` | Boolean | `true` | no | Wraps chart in `FlatPack::Card::Component` with header/body/footer layout. |
| `title` | String, nil | `nil` | no | Optional title shown in card header. |
| `subtitle` | String, nil | `nil` | no | Optional subtitle shown under title. |
| `**system_arguments` | Hash | `{}` | no | Forwarded HTML attributes for outer container in chart-only mode. |

## Slots
| Slot | Description |
| --- | --- |
| `top_right_slot` | Header action area (for buttons, filters, menus) when `card: true`. |
| `footer` | Card footer content when `card: true`. |

## Variants
- Chart type variant via `type`
- Framed (`card: true`) and inline (`card: false`) rendering
- Axis defaults for line/column/bar/area/radar and non-axis defaults for donut/pie
- Funnel defaults for `:funnel` render through ApexCharts' bar chart mode with funnel plot options, stepped primary-color segments, and funnel-specific bar sizing
- Gauge defaults for `:gauge` (`radialBar`) with rounded arc ends and primary-color shading

## Color Defaults
- By default, charts derive their series palette from `--color-primary`.
- When multiple colors are needed, the component uses six opacity steps from the same primary color in descending strength: `100%`, `90%`, `70%`, `50%`, `30%`, and `10%`.
- Area charts use a dedicated line-color opacity ramp (`100%`, `85%`, `70%`, `55%`, `40%`, `25%`) so multiple series are easier to distinguish while keeping the area fill at `10%` primary color.
- Funnel charts reuse the same stepped primary palette so each stage stays visually consistent with the rest of the chart family; the chart controller resolves CSS color functions to computed colors before handing options to ApexCharts.
- If you provide `options[:colors]`, your values are used as-is and override the default theme-derived palette.

## Related Classes
- `FlatPack::Chart::DefaultFilterComponent`: reusable date range + status filter row designed for chart dashboards.

### DefaultFilter Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `start_date_name` | String | `"start_date"` | no | GET/POST param name for the range start date hidden input. |
| `end_date_name` | String | `"end_date"` | no | GET/POST param name for the range end date hidden input. |
| `start_date_value` | String, Date, nil | `nil` | no | Selected start date value passed to DateInput range state. |
| `end_date_value` | String, Date, nil | `nil` | no | Selected end date value passed to DateInput range state. |
| `status_name` | String | `"status"` | no | Form param name for the status select input. |
| `status` | String, nil | `nil` | no | Selected status value. |
| `status_lists` | Array, Hash | — | yes | Select options in any `FlatPack::Select::Component`-supported format. |
| `status_placeholder` | String, nil | `"All"` | no | Placeholder option label for the status select. |
| `hide_labels` | Boolean | `false` | no | When true, omits rendering the Date Range and Status form labels. |
| `minimized` | Boolean | `true` | no | When true, renders desktop inline controls and mobile `FlatPack::ModalFilter::Component` modal flow. |
| `minimized_options` | Hash | `{}` | no | Required when `minimized: true`; include `form_url` and `turbo_frame` for Turbo updates. |

### DefaultFilter minimized_options
| key | type | required | description |
| --- | --- | --- | --- |
| `form_url` | String | no | Form submission URL for desktop and mobile filter flows. Defaults to current request path. |
| `turbo_frame` | String | no | Turbo Frame target for filter submissions. |
| `id` | String | no | Base id for generated modal/form ids. Defaults to `"chart-default-filter"`. |
| `active_count` | Integer | no | Mobile trigger count (`Filter {count}`). |
| `reset_url` | String, nil | no | Optional reset link rendered in mobile modal actions. |
| `trigger_label` | String | no | Mobile trigger label. Default: `"Filter"`. |
| `modal_title` | String | no | Mobile modal title. Default: `"Filters"`. |
| `submit_label` | String | no | Mobile apply label. Default: `"Apply"`. |
| `reset_label` | String | no | Mobile reset label. Default: `"Reset"`. |
| `auto_submit_desktop` | Boolean | no | Enables debounced auto-submit on desktop form. Default: `true`. |
| `auto_submit_delay` | Integer | no | Debounce delay for desktop form submit. Default: `250`. |
| `desktop_form_class` | String, nil | no | Extra classes for desktop form element. |
| `mobile_form_class` | String, nil | no | Extra classes for mobile form element. |
| `mobile_fields_class` | String | no | Extra classes for internally generated mobile fields wrapper. Default: `"grid gap-3"`. |

## Example
```erb
<%= render FlatPack::Chart::Component.new(
  type: :column,
  series: [{ name: "Revenue", data: [44, 55, 57, 56] }],
  options: { xaxis: { categories: ["Q1", "Q2", "Q3", "Q4"] } },
  title: "Quarterly Revenue"
) %>
```

```erb
<%= render FlatPack::Chart::Component.new(
  type: :bar,
  series: [{ name: "Tickets", data: [84, 72, 65, 48, 39] }],
  options: { xaxis: { categories: ["API", "Billing", "Onboarding", "Integrations", "Security"] } },
  title: "Support Queue by Team"
) %>
```

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
  <% chart.top_right_slot do %>
    <%= render FlatPack::Button::Component.new(text: "Export", size: :sm, style: :ghost) %>
  <% end %>
<% end %>
```

```erb
<%= form_with url: demo_charts_path, method: :get do %>
  <%= render FlatPack::Chart::DefaultFilterComponent.new(
    start_date_value: params[:start_date],
    end_date_value: params[:end_date],
    status: params[:status],
    status_lists: [["Active", "active"], ["Paused", "paused"], ["Archived", "archived"]],
    hide_labels: true
  ) %>

  <%= render FlatPack::Button::Component.new(text: "Apply filters", type: "submit", size: :sm) %>
<% end %>
```

```erb
<%= render FlatPack::Chart::DefaultFilterComponent.new(
  start_date_value: params[:start_date],
  end_date_value: params[:end_date],
  status: params[:status],
  status_lists: [["Active", "active"], ["Paused", "paused"], ["Archived", "archived"]],
  minimized: true,
  minimized_options: {
    id: "chart-default-filter",
    form_url: demo_charts_default_filter_path,
    turbo_frame: "chart-default-filter-frame",
    active_count: @default_chart_filter_active_count,
    reset_url: demo_charts_default_filter_path,
    desktop_form_class: "mb-4",
    mobile_form_class: "space-y-4"
  }
) %>
```

```erb
<%= render FlatPack::Chart::Component.new(
  type: :gauge,
  series: [67],
  title: "SLA Compliance",
  subtitle: "Current period",
  options: {
    labels: ["SLA"]
  }
) %>
```

```erb
<%= render FlatPack::Chart::Component.new(
  type: :funnel,
  series: [{ name: "Funnel Series", data: [1380, 1100, 990, 880, 740, 548, 330, 200] }],
  title: "Recruitment Funnel",
  subtitle: "Primary-color stepped stages",
  height: 350,
  options: {
    xaxis: {
      categories: ["Sourced", "Screened", "Assessed", "HR Interview", "Technical", "Verify", "Offered", "Hired"]
    }
  }
) %>
```

```erb
<%= render FlatPack::Table::Component.new(data: repositories) do |table| %>
  <% table.column(title: "Repository", html: ->(row) { row[:name] }) %>
  <% table.column(title: "Activity", html: ->(row) {
    render FlatPack::Chart::Component.new(
      type: :area,
      series: [{ name: "Commits", data: row[:activity] }],
      card: false,
      height: 56,
      options: {
        chart: { sparkline: { enabled: true } },
        tooltip: { enabled: false },
        grid: { show: false },
        xaxis: { labels: { show: false }, axisBorder: { show: false }, axisTicks: { show: false } },
        yaxis: { show: false }
      }
    )
  }) %>
<% end %>
```

Use this compact pattern for dense tabular contexts such as repository activity rows. Keep `card: false`, small `height`, and sparkline-style options so the chart reads as a trend indicator instead of a full analytics panel.

## Accessibility
- Provide meaningful `title`/`subtitle` or nearby text that describes chart intent.
- For critical data, provide a tabular or textual alternative outside the chart canvas.
- Avoid relying only on color to communicate state across series.

## Dependencies
- Stimulus controller: `app/javascript/flat_pack/controllers/chart_controller.js` (`flat-pack--chart`).
- ApexCharts import map pin (`import "apexcharts"` via dynamic import in controller).
- `FlatPack::Card::Component` when `card: true`.
- `FlatPack::DateRangeInput::Component` for date-range selection.
- `FlatPack::Select::Component` for status selection options.
