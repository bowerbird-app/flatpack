# Page Nav

## Purpose
Render a compact icon-only page navigation row with a browser-history back control plus optional close and add link actions.

## When to use
Use Page Nav when the layout needs quick icon actions at the top of a page: go back, close/cancel, and add/create.

## Class
- `FlatPack::PageNav::Component`

## Props
| name | type | default | required | description |
| --- | --- | --- | --- | --- |
| `back_icon` | String | `"chevron-left"` | no | Icon name for the back button. |
| `back_label` | String | `"Go back"` | no | Accessible label for back icon button. |
| `back_style` | Symbol | `:secondary` | no | Button style for back action. |
| `back_size` | Symbol | `:md` | no | Button size for back action. |
| `close_url` | String, nil | `nil` | no | When present, renders the middle close icon as a link. |
| `close_icon` | String | `"x-mark"` | no | Icon name for close action. |
| `close_label` | String | `"Close"` | no | Accessible label for close icon link. |
| `close_style` | Symbol | `:secondary` | no | Button style for close action. |
| `close_size` | Symbol | `:md` | no | Button size for close action. |
| `add_url` | String, nil | `nil` | no | When present, renders the right add icon as a link. |
| `add_icon` | String | `"plus"` | no | Icon name for add action. |
| `add_label` | String | `"Add"` | no | Accessible label for add icon link. |
| `add_style` | Symbol | `:secondary` | no | Button style for add action. |
| `add_size` | Symbol | `:md` | no | Button size for add action. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes and classes for the wrapper nav element. |

## Slots
None.

## Variants
- Back only (default)
- Back + close (`close_url`)
- Back + add (`add_url`)
- Back + close + add (`close_url` and `add_url`)

## Example
```erb
<%= render FlatPack::PageNav::Component.new(
  close_url: demo_path,
  add_url: demo_forms_path
) %>
```

## Accessibility
- Wrapper renders `nav[aria-label="Page navigation"]`.
- Icon-only controls include explicit `aria-label` values.
- Back action uses a button (`window.history.back()`), while close/add use links when URLs are provided.

## Dependencies
- `FlatPack::Button::Component` for icon-only button rendering and URL sanitization.
- `flat-pack--page-nav` Stimulus controller for browser history back behavior.
