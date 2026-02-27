# Page Title

## Purpose
Render a lightweight page title block with optional subtitle.

## When to use
Use Page Title for page-level headings when you do not want the bordered visual treatment of `PageHeader`.

## Class
- Primary: `FlatPack::PageTitle::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Primary page heading text. |
| `subtitle` | String | `nil` | no | Supporting text rendered below title. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for outer wrapper. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::PageTitle::Component.new(
  title: "Team settings",
  subtitle: "Control membership and permissions"
) %>
```

## Accessibility
- Uses semantic `h1` heading.
- Keep subtitle concise and meaningful for screen-reader context.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
