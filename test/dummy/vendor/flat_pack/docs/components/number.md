# Number

## Purpose
Count, roll, or fade a number into place when it scrolls into view. The finished value is already in the page.

## When to use
Use it for a total, a price, a percent, or a compact count that should arrive once. Skip it for billing plans and invoices. Those stay on host-formatted `price_text` and `amount`.

## Class
- Primary: `FlatPack::Number::Component`
- Related classes: `FlatPack::Reveal::Component`, `FlatPack::Text::Stream::Component`

## Props

| name | type | default | required | description |
|------|------|---------|----------|-------------|
| `value` | Numeric or String | none | Yes | The amount. A number, or a plain numeric string. Blank, HTML-safe, and non-finite values raise `ArgumentError`. |
| `from` | Numeric or String | `0` | No | Where a count or roll begins. |
| `format` | Symbol | `:number` | No | `:number`, `:currency`, `:percent`, or `:compact`. Percent is a ratio: `0.18` is 18%. |
| `currency` | String | none | With `:currency` | A three-letter code such as `"USD"`. Required for `:currency`. Raises on any other format. |
| `decimals` | Integer | none | No | `0`–`20`. Sets both the minimum and maximum fraction digits. Omit it and the format uses its own places. |
| `prefix` | String | none | No | Text before the formatted number. HTML-safe strings raise. |
| `suffix` | String | none | No | Text after the formatted number. HTML-safe strings raise. |
| `duration` | Symbol | `:slow` | No | `:fast`, `:base`, or `:slow`. Sets `--fp-number-duration` from `--motion-duration-*`. |
| `animate` | Symbol | `:count` | No | `:count` eases the number. `:roll` is a per-digit odometer. `:fade` fades the finished value in. `:none` shows it at once. |
| `tag` | Symbol | `:span` | No | Root element. Allowed: `:div`, `:span`, `:p`, `:h1`, `:h2`, `:h3`, `:h4`, `:h5`, `:h6`, `:blockquote`, `:li`. |
| `**system_arguments` | Hash | `{}` | No | HTML attributes on the root. `class` and `style` are merged. |

## Slots
None.

## Variants
`:count` is the default. `:roll` lines the digits up with the finished string, so a start of `0` and a finish of `1,240` begins at `0,000`. `:fade` only changes opacity. `:none` adds `is-static` and skips the motion.

The width is the finished string, in tabular figures, so the tick does not shove the layout.

## Example

```erb
<%= render FlatPack::Number::Component.new(value: 2480) %>
<%= render FlatPack::Number::Component.new(value: 1280, format: :currency, currency: "USD", animate: :roll) %>
<%= render FlatPack::Number::Component.new(value: 0.64, format: :percent, animate: :fade) %>
<%= render FlatPack::Number::Component.new(value: 12_000, format: :compact) %>
<%= render FlatPack::Number::Component.new(value: 18, prefix: "About ", suffix: " left", animate: :none) %>
```

A later change animates from the number on screen to the new one. Change the value attribute, or call `setValue` on the controller:

```javascript
element.setAttribute("data-flat-pack--number-value-value", "3600")
```

## Accessibility
The finished string is in `.fp-number__final` and stays in the accessibility tree. The sizer and the animated stage are `aria-hidden`. Nothing is a live region, so a screen reader does not hear each tick.

With no JavaScript the finished string is what you see. `prefers-reduced-motion: reduce` does the same: the controller adds `is-static`, and the CSS shows the finished string at once.

## Dependencies
- Stimulus controller `flat-pack--number` (`app/javascript/flat_pack/controllers/number_controller.js`). The first play waits on `observeOnce` in `reduced_motion.js`, the same in-view trigger as a reveal.
- `--motion-duration-fast`, `--motion-duration-base`, `--motion-duration-slow`, and `--motion-ease-out`.
- The server format follows the host `number.format` delimiter and separator, and matches `Intl.NumberFormat` for English. The browser uses `Intl.NumberFormat` for the ticks and for a later update, with the page locale.
- FlatPack install generator setup (`rails generate flat_pack:install`).
