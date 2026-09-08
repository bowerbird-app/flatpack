# Skip link

## Purpose
Offer keyboard users a first-tab jump past repeated chrome into the main landmark.

## When to use
Put one skip link as the first focusable node in the body. Pair it with `id="main"` and `tabindex="-1"` on `<main>`.

## Class
- Primary: `FlatPack::SkipLink::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `href` | String | `"#main"` | no | In-page fragment only (`#main`). Other URLs raise `ArgumentError`. |
| `text` | String | `"Skip to content"` | no | Visible label when the link is focused. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the anchor. |

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::SkipLink::Component.new(href: "#main") %>
<main id="main" tabindex="-1">
  <%= yield %>
</main>
```

The sidebar layout generator and dummy layouts include this wiring.

## Accessibility
- The control stays in tab order. It is visually hidden until `:focus-visible`.
- Under `prefers-reduced-motion: reduce`, hiding uses clip instead of a transform.
- `tabindex="-1"` on the target lets the skip land without trapping later tabs.

## Dependencies
- Kit class `.fp-skip-link`.
- Tokens: `--skip-link-background-color`, `--skip-link-text-color`.
