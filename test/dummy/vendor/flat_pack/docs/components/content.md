# Content

## Purpose
Wrap long-form HTML in a `div.fp-content` so bare `h1`, `p`, `ul`, and the rest pick up the kit reading scale. Same sizes and spacing as the main Content demo: kicker, display title, lead, then body at 16px / 1.75.

## When to use
Use Content for marketing copy, editorial sections, docs, and CMS / WYSIWYG HTML. Drop the HTML in as-is. Do not use it for UI chrome, forms, or tables. Prefer `FlatPack::ContentEditor::Component` when the same region must be edited in place.

## Class
- Primary: `FlatPack::Content::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the `.fp-content` wrapper `div`. |

## Slots
None. Pass the article HTML as the block. The block argument is the component instance (`do |content|`).

## Variants
None. Descendant selectors style bare tags. Optional classes if you want to force a role:
- First `p` before an `h1` / `h2` / `h3` is the kicker (or add `.fp-content-kicker`).
- First `p` after `h1` is the lead (or add `.fp-content-lead`).

## Example
```erb
<%= render FlatPack::Content::Component.new do |content| %>
  <p>Publish faster</p>
  <h1>A mastered workflow</h1>
  <p>Stories deserve a platform as refined as the prose.</p>
  <p>Body copy, lists, and headings take the kit scale without extra classes.</p>
<% end %>
```

## Accessibility
- Wrapper is a `div`. Put headings in rank order (`h1` then `h2`) inside the block.
- Icon lists that should not show bullets keep `role="list"`.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Theme tokens: `--content-p-size` (`--text-base`), `--content-lead-size`, `--content-h1-size` (`--text-4xl`, 3rem from `640px`), `--content-h2-size` through `--content-h6-size`, `--content-kicker-size`.
- Styles ship unlayered in `flat_pack/application.css` on `.fp-content p`, `.fp-content h1`, and the other tags.
