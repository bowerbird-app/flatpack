# Content

## Purpose
Wrap long-form HTML so body copy, headings, lists, and links share one reading type scale. Paragraphs are 18px (`--text-lg`).

## When to use
Use Content for marketing copy, editorial sections, docs, and CMS HTML. Do not use it for UI chrome, forms, or tables. Prefer `FlatPack::ContentEditor::Component` when the same region must be edited in place.

## Class
- Primary: `FlatPack::Content::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the `.fp-content` wrapper `div`. |

## Slots
None. Pass the article HTML as the block. The block argument is the component instance (`do |content|`).

## Variants
None. Optional descendant classes:
- `.fp-content-kicker` — small primary label above the title.
- `.fp-content-lead` — intro paragraph one step larger than body copy.

## Example
```erb
<%= render FlatPack::Content::Component.new do |content| %>
  <p class="fp-content-kicker">Publish faster</p>
  <h1>A mastered workflow</h1>
  <p class="fp-content-lead">Stories deserve a platform as refined as the prose.</p>
  <p>Body copy sits at 18px. Headings, lists, and links scale from that size.</p>
<% end %>
```

## Accessibility
- Wrapper is a `div`. Put headings in rank order (`h1` then `h2`) inside the block.
- Icon lists that should not show bullets keep `role="list"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Theme tokens: `--content-p-size` (18px via `--text-lg`), `--content-lead-size`, `--content-h1-size` through `--content-h6-size`, `--content-kicker-size`.
- Styles ship unlayered in `flat_pack/application.css` on `.fp-content` so host Tailwind preflight cannot inherit heading size.
