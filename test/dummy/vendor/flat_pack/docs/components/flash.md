# Flash

## Purpose
Turn a Rails flash hash the caller passes into stacked alerts or toasts.

## When to use
Use Flash when a controller set `flash` and the page should show those messages with Flatpack. Pass the hash in. Pick `as: :alert` when the message should stay in place, or `as: :toast` when it should use the toast timeout.

## Class
- Primary: `FlatPack::Flash::Component`
- Related classes: `FlatPack::Notice::Component`, `FlatPack::Alert::Component`, `FlatPack::Toast::Component`, `FlatPack::Toasts::Region::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `flash` | Hash | — | yes | The flash hash for this render. A `Hash` or `ActionDispatch::Flash::FlashHash`. String values render once. Array values render one message per string. Blank strings are skipped. Other values are skipped. |
| `as` | Symbol | — | yes | `:alert` stacks alerts in place. `:toast` renders toasts in a toast region. Anything else raises `ArgumentError`. |
| `styles` | Hash | `{}` | no | Key to style overrides for this call, merged over the defaults. Values must be `:info`, `:success`, `:warning`, or `:danger`. In alert mode, `:info` and `:success` render Notice. `:warning` and `:danger` render Alert. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the alert stack, or for the toast region when `as` is `:toast`. |

## Slots
None.

## Variants
Default key to style map:

| flash key | style | component |
|---|---|---|
| `notice` | `:success` | `FlatPack::Notice::Component` |
| `info` | `:info` | `FlatPack::Notice::Component` |
| `success` | `:success` | `FlatPack::Notice::Component` |
| `alert` | `:danger` | `FlatPack::Alert::Component` |
| `error` | `:danger` | `FlatPack::Alert::Component` |
| `danger` | `:danger` | `FlatPack::Alert::Component` |
| `warning` | `:warning` | `FlatPack::Alert::Component` |
| anything else | `:info` | `FlatPack::Notice::Component` |

`styles: {saved: :success}` adds or replaces a key for that call. The defaults stay in place for every other key. In alert mode, a style Notice allows (`:info`, `:success`) renders Notice. Any other allowed style renders Alert.

## Example
```erb
<%= render FlatPack::Flash::Component.new(flash: flash, as: :toast) %>

<%= render FlatPack::Flash::Component.new(
  flash: flash,
  as: :alert,
  styles: {saved: :success}
) %>
```

Alert mode renders one Notice or Alert per message, stacked with `gap-4`. Notice is `role="status"`. Alert is `role="alert"`. Toast mode renders one `FlatPack::Toast::Component` per message inside `FlatPack::Toasts::Region::Component`. The toast controller shows each toast and dismisses it on the toast timeout (`5000` by default). Toast mode does not use Notice.

A Turbo visit, frame, or stream that includes this markup connects the same toast controller when the nodes are inserted. There is no separate flash controller.

The component renders where you call it. It does not read `flash` from the controller, and it does not choose a corner of the page. Toast placement is the toast region's.

## Accessibility
Alert mode uses `role="status"` on Notice and `role="alert"` on Alert. Toast mode keeps the region's polite live region and each toast's `role="status"`. Message text is escaped and read as text.

## Dependencies
- `FlatPack::Notice::Component` and `FlatPack::Alert::Component` when `as` is `:alert`.
- `FlatPack::Toast::Component` and `FlatPack::Toasts::Region::Component` when `as` is `:toast`.
- Stimulus controller `flat-pack--toast` on each toast. The region does not require `flat-pack--toasts-region` for messages that are already in the HTML.
