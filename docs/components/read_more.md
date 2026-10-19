# Read More

## Purpose
Clamp a block to a few lines, then let someone open the rest.

## When to use
Use Read More for a note, a bio, or a short article that should stay compact until someone asks for the rest. It is not Collapse. Collapse is a titled disclosure that hides its panel. It is not Content. Content sets the reading scale for article HTML. Put Content inside Read More when the clamped block is article HTML.

## Class
- Primary: `FlatPack::ReadMore::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `lines` | Integer | `4` | no | Clamp budget in line boxes. Must be a positive integer. `0`, negatives, floats, and strings raise `ArgumentError` with `lines must be a positive integer`. |
| `open` | Boolean | `false` | no | Exactly `true` or `false`. Anything else raises `ArgumentError` with `open must be true or false`. `true` starts expanded. |
| `more_label` | String | `flatpack.read_more.more` | no | Button label while closed. Omit it for the locale string (`Show more` in English). A blank value, `nil`, or an HTML-safe string raises `ArgumentError`. |
| `less_label` | String | `flatpack.read_more.less` | no | Button label while open. Omit it for the locale string (`Show less` in English). Same string rules as `more_label`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the root. `class` merges with `fp-read-more`. A caller `data-controller` is kept. `id` stays on the root. `style` is kept, and `--read-more-lines` is appended. |

## Slots
The default block is the clamped body. An empty block is allowed. The block is rendered as given. Read More does not mark it HTML-safe.

## Variants
`open: false` clamps the clip to `lines`. `open: true` starts at `max-content`. The fade appears only when the clip is closed and the body overflows.

## Example
```erb
<%= render FlatPack::ReadMore::Component.new(lines: 4) do %>
  <p>The kettle is on.</p>
<% end %>

<%= render FlatPack::ReadMore::Component.new(lines: 3, open: true, more_label: "Keep reading", less_label: "That's enough") do %>
  <p>We took the long way home, past the bakery that still sells yesterday's buns.</p>
<% end %>
```

## Accessibility
The toggle is a `button` with `type="button"`. `aria-expanded` is the string `"true"` or `"false"`. `aria-controls` points at the clip. A caller `id` stays on the root, and the clip id is `"#{id}-content"`. With no caller id, the clip id is generated. The button stays in the page and is hidden until the body is taller than the clamp. The clamp is visual. The full text stays in the document.

## Dependencies
- `FlatPack::Button::Component` renders the toggle at `style: :ghost` and `size: :sm`.
- Styles ship unlayered in `flat_pack/application.css` on `.fp-read-more`, after `@layer components`.
- `.fp-read-more-line` is the `1lh` strut. The controller reads that element's height when it decides overflow.
- Stimulus controller `flat-pack--read-more` (`read_more_controller.js`). It reads `open` and `overflowing`. It does not set `max-height`.
- Importmap hosts already pin `app/javascript/flat_pack/controllers` with `pin_all_from`. Do not add a pin. Do not rerun `bin/rails generate flat_pack:install`.
- No Tailwind rebuild. The clamp and the fade live in kit CSS. The button reuses the ghost button classes the kit already ships.
- esbuild, webpack, and Vite hosts must register the controller. Import `ReadMoreController` from `read_more_controller.js` and call `application.register("flat-pack--read-more", ReadMoreController)`.
- `--read-more-fade-height` is `2.5rem` on `:root, [data-theme]`. `--read-more-lines` is set on the component root at render time. Do not declare `--read-more-lines` in a theme.
- The open height uses `interpolate-size: allow-keywords`. Where that property is missing, the height snaps. The clamp still works. Reduced motion sets `--duration-slow` to `0ms`, so the height snaps there too.
