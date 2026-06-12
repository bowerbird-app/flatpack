# Chart Buttons

## Purpose
Render generic chart-adjacent filter controls that target Turbo Frames without coupling control behavior to `FlatPack::Chart::Component` internals.

## When to use
Use this as a sibling controls container when chart filtering UI can vary by screen and may include buttons, dropdowns, checkboxes, or custom controls.

## Class
- Primary: `FlatPack::ChartButtons::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `turbo_frame` | String, nil | `nil` | no | Default Turbo Frame target inherited by control helpers unless overridden per control. |
| `turbo_prefetch` | Boolean, nil | `false` | no | Default Turbo prefetch behavior for link-based control helpers. |
| `control_size` | Symbol | `:sm` | no | Default size for helper-generated button and dropdown triggers. |
| `margin_bottom` | String, nil | `"mb-3"` | no | Bottom margin utility applied to the wrapper; set to `nil` to remove the default spacing or override with another utility class. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the controls container wrapper. |

## Slots
| name | type | description |
| --- | --- | --- |
| `control` | slot | Accepts a custom component instance or block content for fully custom controls. |
| `button` | helper | Renders a Turbo link button helper (`text`, `url`, `selected`, and forwarded button args). |
| `dropdown` | helper | Renders a dropdown helper with Turbo-linked options. |
| `checkbox` | helper | Renders a Turbo GET form with checkbox toggle behavior and optional auto-submit. |

## Variants
None.

## Example
```erb
<%= render FlatPack::ChartButtons::Component.new(turbo_frame: "chart-period-filter") do |controls| %>
  <% controls.button(
    text: "Day",
    url: demo_charts_path(period: "day", compare: "0"),
    selected: params[:period] == "day"
  ) %>

  <% controls.dropdown(
    text: "Range",
    style: :ghost,
    options: [
      { text: "Day", url: demo_charts_path(period: "day", compare: params[:compare]) },
      { text: "Week", url: demo_charts_path(period: "week", compare: params[:compare]), selected: true }
    ]
  ) %>

  <% controls.checkbox(
    name: "compare",
    label: "Compare baseline",
    checked: params[:compare] == "1",
    url: demo_charts_path(period: params[:period])
  ) %>

  <% controls.control do %>
    <%= render FlatPack::Button::Component.new(
      text: "Reset",
      style: :ghost,
      size: :sm,
      url: demo_charts_path(period: "day", compare: "0"),
      data: { turbo_frame: "chart-period-filter", turbo_prefetch: false }
    ) %>
  <% end %>
<% end %>
```

## Accessibility
- Provide meaningful labels for every control, especially checkbox and dropdown trigger text.
- Keep selected/toggled state semantic by using `selected` and `aria` overrides where applicable.
- Ensure custom slot controls expose accessible names and state attributes appropriate to their control type.

## Dependencies
- Optional Stimulus controller: `app/javascript/flat_pack/controllers/chart_buttons_controller.js` for checkbox auto-submit helper behavior.
- Uses existing FlatPack control primitives (`Button`, `Button::Dropdown`, `Checkbox`).
