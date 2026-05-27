# Page Title

## Purpose
Render a lightweight page heading block with optional subtitle and semantic heading level control.

## When to use
Use Page Title for page-level headings when you do not want the bordered visual treatment of `PageHeader`.

## Class
- Primary: `FlatPack::PageTitle::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Primary page heading text. |
| `subtitle` | String | `nil` | no | Supporting text rendered below title. |
| `variant` | Symbol, String | `:h1` | no | Semantic heading tag. One of `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`. |
| `large_subtitle` | Boolean | `false` | no | When `true`, subtitle matches the selected heading variant size (`h1`-`h6`), uses bold weight, and removes top margin. |
| `title_color` | String | `nil` | no | Optional CSS color override for the rendered heading tag (`h1`-`h6`). |
| `subtitle_color` | String | `nil` | no | Optional CSS color override for subtitle `p` text. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for outer wrapper. |

## Slots
| name | type | description |
|---|---|---|
| `actions` | Block | Optional action content rendered directly below the subtitle, or directly below the title when no subtitle is present. |

## Variants
- Heading level variants: `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`

## Example
```erb
<%= render FlatPack::PageTitle::Component.new(
  title: "Team settings",
  subtitle: "Control membership and permissions",
  variant: :h2,
  large_subtitle: true,
  title_color: "var(--color-primary)",
  subtitle_color: "oklch(0.35 0.02 250)"
) do |page_title| %>
  <% page_title.actions do %>
    <%= render FlatPack::Button::Component.new(text: "Invite member", style: :secondary, size: :sm) %>
  <% end %>
<% end %>
```

## Behavior
- `actions` renders immediately below the subtitle when `subtitle` is present.
- `actions` renders immediately below the title when `subtitle` is omitted.

## Accessibility
- Uses semantic heading tags via `variant` (`h1`-`h6`).
- Keep subtitle concise and meaningful for screen-reader context.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
