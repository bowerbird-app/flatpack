# Animated character

Draw a small character from a Ruby hash and play named moods on its parts. The same player runs icon presets such as a bell wiggle or a check that draws itself.

## Purpose

Give a screen a tiny illustrated character, or a one-shot icon motion, without embedding SVG or animation markup from the host.

## When to use

Use it for a mascot, an empty-state friend, or a single icon that should wiggle, pop, draw, spin, or nudge. Use Spinner for a loading wait. Do not morph path data. This version only moves, fades, and draws a stroke.

## Class

- Primary: `FlatPack::AnimatedCharacter::Component`
- Related: `FlatPack::AnimatedCharacter.bot`, `FlatPack::AnimatedCharacter.pip`, `FlatPack::Shared::IconComponent`

## Props

| name | type | default | required | description |
|---|---|---|---|---|
| `definition` | Hash |  | yes | Parts and named states. See the shape below. `AnimatedCharacter.bot` and `AnimatedCharacter.pip` are ready-made definitions. |
| `state` | Symbol or String | `:idle` | no | Which state plays on mount. Must be a key in `definition[:states]`. |
| `size` | Symbol | `:xl` | no | `:sm` (`w-10`), `:md` (`w-16`), `:lg` (`w-24`), `:xl` (`w-40`). |
| `label` | String or nil | `nil` | no | Accessible name. When present, the SVG is `role="img"` with `aria-label`. `nil` sets `aria-hidden`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the SVG. |

### Definition

A Hash. Symbol or string keys both work. The component keeps an allowlist and raises `ArgumentError` on anything else.

```ruby
{
  view_box: "0 0 64 64",
  parts: [
    {
      name: "body",
      shapes: [
        { type: "rect", x: 14, y: 22, width: 36, height: 30, rx: 14, fill: "currentColor" }
      ],
      parts: [
        {
          name: "eyes",
          shapes: [
            { type: "circle", cx: 26, cy: 34, r: 3.3, fill: "var(--surface-background-color)" }
          ]
        }
      ]
    }
  ],
  states: {
    blink: {
      tracks: [
        { part: "eyes", property: "scaleY", keyframes: [1, 0.08, 1], duration: 160, easing: "standard" }
      ]
    }
  }
}
```

Shapes are `circle`, `ellipse`, `rect`, `path`, `line`, and `polyline`. Attributes are the usual geometry plus `fill`, `stroke`, `stroke-width`, `stroke-linecap`, `stroke-linejoin`, `fill-rule`, and `opacity`. Paint is `none`, `currentColor`, a hex colour, or `var(--token)`. Path `d` is commands and numbers only.

Parts can nest. Each `name` is a letter, then letters, numbers, or hyphens, and it is unique. A part may set `opacity` from 0 to 1 for a shape that starts hidden.

A track targets a `part` and one `property`: `translateX`, `translateY`, `scaleX`, `scaleY`, `rotate`, `opacity`, or `strokeDashoffset`. `keyframes` is a list of numbers (at least two). A keyframe may be `{ value:, offset: }` when the change should sit at a point in the timeline, from 0 to 1. `duration` is milliseconds, or `:fast`, `:base`, `:slow` (`--duration-fast`, `--duration-base`, `--duration-slow`). `easing` is `standard`, `enter`, `exit`, or `linear` (the `--easing-*` tokens, except `linear`). `delay` is milliseconds. `iterations` is a positive integer or `"infinite"`.

`strokeDashoffset` may use the keyframe `"length"`, which is the shape's measured length. That is how a stroke draws on. Path `d` does not animate.

### Icon presets

`FlatPack::Shared::IconComponent` takes `animate:` and `trigger:`.

| `animate` | motion |
|---|---|
| `:wiggle` | rotate the icon, then settle |
| `:pop` | scale up and settle |
| `:draw` | stroke draws from its length to zero |
| `:spin` | one full turn |
| `:nudge` | a short move on x |

`trigger` is `:hover` (default), `:click`, or `:mount`. The icon stays `aria-hidden`.

## Slots

None.

## Variants

- Sizes via `size`.
- Named vs decorative via `label`.
- Icon motion via `animate` and `trigger` on `FlatPack::Shared::IconComponent`.

## Example

```erb
<%= render FlatPack::AnimatedCharacter::Component.new(
  definition: FlatPack::AnimatedCharacter.bot,
  state: :idle,
  size: :xl,
  label: "Flatpack bot"
) %>

<%= render FlatPack::Shared::IconComponent.new(name: :bell, animate: :wiggle, trigger: :hover) %>
```

The Stimulus controller is `flat-pack--svg-motion`. From another controller, `setState`, `play`, `stop`, `reset`, `pause`, and `resume` are public methods. `setState("blink")` replaces the running tracks.

Demo: `/demo/animated_character`.

## Accessibility

- A `label` makes the SVG `role="img"` with that `aria-label`. Omit `label` and the SVG is `aria-hidden`.
- `prefers-reduced-motion: reduce` leaves the first frame. The controller asks `prefersReducedMotion()` in `controllers/flat_pack/reduced_motion.js`. Nothing autoplays.
- Icon presets do not give the icon a name. Put the meaning on the control around it.

## Dependencies

- Stimulus controller `flat-pack--svg-motion` (`app/javascript/flat_pack/controllers/svg_motion_controller.js`).
- `controllers/flat_pack/reduced_motion` for the reduced-motion check and for `:fast`, `:base`, and `:slow` durations.
- `--duration-fast`, `--duration-base`, `--duration-slow`, `--easing-standard`, `--easing-enter`, `--easing-exit`.
- Heroicons, when an icon uses `animate:`.
