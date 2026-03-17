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
| `**system_arguments` | Hash | `{}` | no | HTML attributes for outer wrapper. |

## Slots
None.

## Variants
- Heading level variants: `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`

## Example
```erb
<%= render FlatPack::PageTitle::Component.new(
  title: "Team settings",
  subtitle: "Control membership and permissions",
  variant: :h2
) %>
```

## Accessibility
- Uses semantic heading tags via `variant` (`h1`-`h6`).
- Keep subtitle concise and meaningful for screen-reader context.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
