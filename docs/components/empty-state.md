# Empty State

## Purpose
Invite the person to do the next useful thing when a list, search, or panel has nothing in it yet.

## When to use
Use Empty State when a surface is blank and the person can act: create the first item, clear filters, connect a source. Lead with that action. The visual above the title is one slot. `icon:` is the default. `media` is one picture that keeps its own shape. `visual` is any host markup, and a block replaces the icon.

## Class
- Primary: `FlatPack::EmptyState::Component`
- Related classes: `FlatPack::Collection::Component`, `FlatPack::Media::Component`, `FlatPack::Shared::IconComponent`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `title` | String | `nil` | yes | Heading that names what is missing. |
| `description` | String | `nil` | no | One sentence on what to do next. |
| `icon` | Symbol/String/false | `nil` | no | Kit icon name (`:inbox`, `:search`, or any `IconComponent` name). Pass `false` or omit to skip. A `visual` block or `media` replaces it. |
| `icon_variant` | Symbol | `nil` | no | Heroicon weight for `icon`: `:outline`, `:solid`, `:mini`, `:micro`. Omit to use `default_icon_variant`. Requires `icon`. |
| `icon_size` | Symbol | from `size` | no | IconComponent size: `:sm`, `:md`, `:lg`, `:xl`. Requires `icon`. Omit and `:sm` maps to `:md`, `:md` to `:lg`, `:lg` to `:xl`. A `media` image does not use this. It stays on `width:`. |
| `size` | Symbol | `:md` | no | Preset for padding, gaps, icon, title, and description: `:sm`, `:md`, `:lg`. Padding and gaps read `--empty-state-*` tokens, which are `calc(var(--space-N) * var(--density))`. |
| `title_size` | Symbol | from `size` | no | Heading step: `:xs`, `:sm`, `:base`, `:lg`, `:xl`, `:xxl`, or `:display`. `:display` uses `.fp-display`. Omit and `:sm` maps to `:base`, `:md` to `:lg`, `:lg` to `:xl`. Not Hero `title_size`. |
| `description_size` | Symbol | from `size` | no | Sentence step: `:sm`, `:md`, `:lg`, or `:xl` (`--text-sm`, `--text-base`, `--text-lg`, `--text-xl`). Omit and it follows `size` under those same names. Not `title_size`. |
| `width` | Symbol | `:md` | no | Max width of the text block: `:sm`, `:md`, `:lg`, or `:full` (`--empty-state-measure-*`). `:md` is `28rem`. `:full` is `max-width: none`. A `media` image uses the same cap. The root does not. |
| `layout` | Symbol | `:wrap` | no | Action arrangement: `:wrap` (wrapping row, centered) or `:stack` (one under the next, stretched to the measure). Renders `FlatPack::Collection::Component`. Not `:grid`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root. |

## Slots
| name | type | required | description |
|---|---|---|---|
| `item` | slot | no | One action. Repeat it. The items render in a Collection using `layout`. |
| `visual` | slot | no | Freeform markup above the title. It spans the empty state, so a large composition fits. Not cropped. Replaces `icon`. |
| `media` | method | no | Fills that same visual with one `FlatPack::Media::Component` (`src`, `alt`, `width`, `height`). The image keeps that aspect ratio and is capped by `width:`. Not a second slot. Replaces `icon`. |

Pass `visual` or `media`, not both.

## Width
The root is a block-level flex column. It sets no width and no max-width, so in normal flow it stretches to the full width of its container. Only the description used to be capped (`max-w-md`). `width:` now caps the whole text block, centred in that full-width root. A `visual` block stays full width of the root so a hero can be wider than the words. A `media` image uses the same cap as the text.

## Variants
- `size:` `:sm`, `:md`, `:lg` sets padding, gaps, the icon, the title, and the description together.
- `title_size:`, `description_size:`, and `icon_size:` override one part of that preset.
- `layout:` `:wrap` or `:stack` for the actions.
- `width:` `:sm`, `:md`, `:lg`, `:full` for the text measure. A media image uses this cap, not `icon_size`.
- `title_size:` including `:display` for a cover heading.
- `description_size:` `:sm` (`--text-sm`), `:md` (`--text-base`), `:lg` (`--text-lg`), `:xl` (`--text-xl`). The default sentence is one step larger than the old mapping: a medium empty state uses `--text-base`.

## Example
```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "No projects yet",
  description: "Create a project to group work in one place.",
  icon: :folder,
  icon_variant: :solid,
  width: :md,
  layout: :wrap
) do |state| %>
  <% state.item do %>
    <%= render FlatPack::Button::Component.new(text: "Create project", style: :primary) %>
  <% end %>
<% end %>
```

A picture instead of an icon:

```erb
<% state.media(src: "/images/harbour.jpg", alt: "Harbour at dusk", width: 1280, height: 850) %>
```

A large opening:

```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "Your story starts with a press kit",
  description: "Share news, assets, and stories with journalists.",
  title_size: :display,
  width: :lg
) do |state| %>
  <% state.visual do %>
    <%# A wide composition. It is not limited to the text measure. %>
  <% end %>
  <% state.item do %>
    <%= render FlatPack::Button::Component.new(text: "Create press kit", style: :primary) %>
  <% end %>
<% end %>
```

A larger sentence on the medium preset:

```erb
<%= render FlatPack::EmptyState::Component.new(
  title: "No projects yet",
  description: "Create a project to group work in one place.",
  description_size: :xl
) %>
```

## Empty then content
The root is `.fp-empty-state`. It fades and rises a few pixels on `--duration-slow` / `--easing-enter` (`@starting-style`). When the first item arrives, hide the empty panel and show content with `.fp-content-enter` so the swap uses the same motion. Reduced motion snaps with no transform.

Dummy `/demo/empty_state` has a Show empty / Show content toggle, an icon, an image, a `visual` block, width, stacked actions, a large opening, each `size`, and a `description_size` override.

## Accessibility
- Title and description are semantic text. The title is an `h3`.
- Put the next step on a real button in `item`, not only in the description.
- Each `item` is an `<li>` inside the Collection list.
- `media` requires `alt` (pass `""` when the picture is decorative). A decorative `visual` should be hidden from assistive tech by the caller.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- `FlatPack::Shared::IconComponent` when `icon` is set.
- `FlatPack::Media::Component` when `media` fills the visual.
- `FlatPack::Collection::Component` when there is at least one `item`.
- Kit CSS: `.fp-empty-state`, `.fp-content-enter`, and the `--empty-state-*` tokens (formulas of `--space-*` and `--density`).
