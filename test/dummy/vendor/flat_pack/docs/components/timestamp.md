# Timestamp

## Purpose
Render human-readable relative time text with an absolute timestamp shown in a tooltip.

Future timestamps render as "In X" while past timestamps render as "X ago".

## When to use
Use Timestamp in activity feeds, tables, and metadata rows where relative recency improves scanability while exact time remains available on hover/focus.

## Class
- `FlatPack::Timestamp::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `timestamp` | Time, DateTime, Date, String, Numeric, nil | — | yes | Input value to parse and render. Numeric values are treated as Unix timestamps. |
| `class_name` | String, nil | `nil` | no | Optional CSS class string applied to the rendered timestamp text (`<time>` or fallback `<span>`). |
| `tooltip_placement` | Symbol | `:top` | no | Tooltip placement: `:top`, `:right`, `:bottom`, `:left`. |
| `fallback_text` | String | `"-"` | no | Text rendered when `timestamp` is nil or cannot be parsed. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes forwarded to tooltip wrapper when timestamp is valid. |

## Slots
None.

## Variants
- Placement variant via `tooltip_placement`.

## Example
```erb
<%= render FlatPack::Timestamp::Component.new(timestamp: 3.minutes.ago) %>
```

```erb
<%= render FlatPack::Timestamp::Component.new(
  timestamp: 15.minutes.from_now,
  tooltip_placement: :right,
  class_name: "text-sm text-[var(--surface-muted-content-color)]"
) %>
```

```erb
<%= render FlatPack::Timestamp::Component.new(timestamp: "2016-01-01T00:00:00Z", class_name: "text-green-600") %>
<%= render FlatPack::Timestamp::Component.new(timestamp: "2016-01-01T00:00:00Z", class_name: "text-xs") %>
```

## Accessibility
- Renders a semantic `<time>` element with a `datetime` ISO8601 value when parsing succeeds.
- Uses `FlatPack::Tooltip::Component`, which supports hover and focus interactions.

## Dependencies
- Rails helper: `ActionView::Helpers::DateHelper#time_ago_in_words`.
- FlatPack component: `FlatPack::Tooltip::Component`.
- Stimulus controller: `flat-pack--timestamp` for local-time tooltip formatting.
