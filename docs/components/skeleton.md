# Skeleton

## Purpose
Render placeholder UI shapes while content is loading.

## When to use
Use Skeleton when data is pending and layout stability should be preserved.

## Class
- Primary: `FlatPack::Skeleton::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `variant` | Symbol | `:text` | no | Shape preset: `:text`, `:title`, `:avatar`, `:button`, `:rectangle`; invalid values raise `ArgumentError`. |
| `width` | String | `nil` | no | Custom width utility value (for example `"240px"`, `"75%"`). |
| `height` | String | `nil` | no | Custom height utility value. |
| `shimmer` | Boolean | `true` | no | Enables shimmer animation when true. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for skeleton element. |

## Slots
None.

## Variants
- `:text`, `:title`, `:avatar`, `:button`, `:rectangle`.

## Example
```erb
<div class="space-y-3">
  <%= render FlatPack::Skeleton::Component.new(variant: :title, width: "60%") %>
  <%= render FlatPack::Skeleton::Component.new(variant: :text) %>
  <%= render FlatPack::Skeleton::Component.new(variant: :text, width: "80%") %>
</div>
```

## Accessibility
- Renders `role="status"` with `aria-busy="true"` and `aria-label="Loading..."`.
- Shimmer animation respects reduced-motion preferences via CSS utility classes.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
