# Search

## Purpose
Render a search input with optional live-result dropdown backed by local items or a JSON endpoint.

## When to use
Use Search where users need quick keyword filtering in top nav or content surfaces.

## Class
- Primary: `FlatPack::Search::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `placeholder` | String | `"Search..."` | No | Input placeholder text. |
| `name` | String | `"q"` | No | Input `name` and query param key used for live search requests. |
| `value` | String | `nil` | No | Initial input value. |
| `search_url` | String | `nil` | No | Enables remote live search when present. URL is sanitized (safe protocols + relative URLs). Ignored when `items` is present. |
| `items` | Array | `[]` | No | Local results to filter in the browser. Each item is `{ title:, description:, url: }`. Prefer this for static catalogs. Title matches rank above description matches, and description matches whole tokens (`form` matches Forms, not "formatting"). |
| `max_width` | Symbol | `:md` | No | Wrapper max width. Allowed: `:none`, `:md`, `:lg`, `:xl`. |
| `size` | Symbol | `:md` | No | Field size. Allowed: `:sm`, `:md`, `:lg`. `:md` matches the previous default height and type. |
| `min_characters` | Integer | `2` | No | Minimum trimmed query length before results are shown. |
| `debounce` | Integer | `250` | No | Debounce delay in milliseconds for remote requests. Not used for local `items`. |
| `no_results_text` | String | `"No results found"` | No | Empty-state text shown in dropdown when no results match. |
| `collapsible` | Boolean | `false` | No | Rest as a round icon button that grows into this field. Off leaves today's markup alone. |
| `collapsed` | Boolean | `true` | No | Starting posture when `collapsible` is on. `false` starts expanded. A present `value` stays open either way. |
| `grow` | Symbol | `:end` | No | Which way the field grows. `:end` keeps the start edge put. `:start` keeps the end edge put, for a control on the trailing side of a toolbar. |
| `**system_arguments` | Hash | `{}` | No | Standard HTML attributes merged into the wrapper/input (`class`, `id`, `data`, `aria`). `aria: { label: }` names the round button. |

## Slots
None.

## Variants
- Sizes: `:sm`, `:md` (default), `:lg`

## Example

```erb
<%= render FlatPack::Search::Component.new(
  items: [
    {title: "Buttons", description: "Button variants", url: "/demo/buttons"}
  ],
  placeholder: "Search components...",
  size: :lg
) %>
```

Remote live search still works when you need a server query:

```erb
<%= render FlatPack::Search::Component.new(
  search_url: search_results_path,
  placeholder: "Search components..."
) %>
```

Expected live-search response shape:

```json
{
  "results": [
    {
      "title": "Buttons",
      "description": "Button variants and examples",
      "url": "/demo/buttons"
    }
  ]
}
```

The controller also accepts a top-level JSON array instead of `{ "results": [...] }`.

Local `items:` ranking prefers exact title, then title prefix, then title substring, then whole description tokens. Dummy top-nav search uses `items: DemoCatalog.searchable_items`.

## Collapsible toolbar

`collapsible: true` rests the field as a round icon button. The button is `FlatPack::Button` with `round: true` and `icon_only: true`, so it matches a bell beside it. Click, Enter, or Space grows the shell to `--search-expanded-width` (capped at the parent's width) and focuses the input. The open field uses the same icon, padding, and clear button as a plain search. Escape, a click outside, or blur while the focused field is empty collapses it and returns focus to the button. A click elsewhere leaves an open field alone until that field holds focus. Tabbing to another control collapses an empty field and leaves focus on that control. A typed value stays open. Enter still submits a host form. Search itself is not a form.

`grow: :end` (default) anchors the start edge. `grow: :start` anchors the end edge, so a trailing toolbar slot opens back into the bar. On a narrow row the open width is `min(100%, var(--search-expanded-width))` and the shell can shrink beside a sibling.

```erb
<div class="flex items-center gap-2">
  <%= render FlatPack::Search::Component.new(
    collapsible: true,
    grow: :start,
    placeholder: "Search the kit"
  ) %>
  <%= render FlatPack::Button::Component.new(
    icon: "bell",
    icon_only: true,
    round: true,
    aria: { label: "Notifications" }
  ) %>
</div>
```

The button's accessible name is `flatpack.common.search` ("Search"). Pass `aria: { label: }` to replace it. `aria-expanded` and `aria-controls` live on that button. Live search keeps its own `aria-expanded` on the input.

## Accessibility
When live search is enabled (`items` or `search_url`), the input includes `aria-haspopup="listbox"` and toggles `aria-expanded` as the dropdown opens/closes. `Escape` closes the dropdown. On a collapsible field that is empty, that same Escape then collapses the field.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Live search behavior requires Stimulus controller `flat-pack--search`.
- `collapsible: true` requires Stimulus controller `flat-pack--search-collapse`. Importmap hosts already pin the controllers directory. esbuild, webpack, and Vite hosts register `flat-pack--search-collapse` by hand.
- The search icon is aligned by `FlatPack::Shared::IconComponent` (block SVG; magnifying-glass, plus, and minus are optically nudged). Add other handle-heavy icons to `IconComponent::OPTICAL_NUDGES` instead of Search CSS.
