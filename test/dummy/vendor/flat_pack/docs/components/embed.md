# Embed

## Purpose
Show a hosted iframe in a reserved frame, with a required accessible name.

## When to use
Use Embed for a map, a clip, a form, or any other page the host already has a URL for. Flatpack does not know about providers and does not build embed URLs. Pass `src:` yourself.

Do not use it for a still that should play later (that is `FlatPack::VideoPreview::Component`) or for a photo (that is `FlatPack::Media::Component`).

## Class
- Primary: `FlatPack::Embed::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `src` | String |  | yes | Iframe URL. `http(s)` or a relative URL. Anything else raises `ArgumentError`. |
| `title` | String |  | yes | Accessible name of the iframe. The host translates this string. Blank values raise `ArgumentError`. |
| `aspect_ratio` | String | `"16/9"` | no | Frame shape. Same values as Card media: `"16/9"`, `"4/3"`, `"1/1"` (`aspect-square`), or a custom ratio such as `"21/9"`. Invalid values raise `ArgumentError`. |
| `allow` | String | `nil` | no | Permissions Policy string on the iframe. Omit the attribute when unset. |
| `sandbox` | String | `nil` | no | Iframe sandbox tokens, or `""` for the strict sandbox. Omit the attribute when unset. |
| `loading` | String | `"lazy"` | no | `"lazy"` or `"eager"`. Anything else raises `ArgumentError`. |
| `referrerpolicy` | String | `"strict-origin-when-cross-origin"` | no | Iframe referrer policy. Allowed values: `no-referrer`, `no-referrer-when-downgrade`, `origin`, `origin-when-cross-origin`, `same-origin`, `strict-origin`, `strict-origin-when-cross-origin`, `unsafe-url`. |
| `caption` | String | `nil` | no | Optional figcaption. A block can supply the same copy when `caption:` is omitted. |
| `allowfullscreen` | Boolean | `false` | no | Sets the iframe `allowfullscreen` attribute when `true`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes merged into the `<figure>`. |

## Slots
None. Optional caption copy can be passed as `caption:` or as the component block.

## Variants
None. `aspect_ratio` sets the frame shape.

## Example
```erb
<%= render FlatPack::Embed::Component.new(
  src: map_embed_url,
  title: "Studio location",
  aspect_ratio: "4/3",
  caption: "The workshop on OpenStreetMap"
) %>
```

A clip with permissions and fullscreen:

```erb
<%= render FlatPack::Embed::Component.new(
  src: trailer_embed_url,
  title: "Launch trailer",
  aspect_ratio: "16/9",
  allow: "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture",
  allowfullscreen: true
) %>
```

## Accessibility
`title:` is the iframe's accessible name. Screen readers announce it. Do not leave it blank. Pair a `caption:` when the visible label should sit under the frame; the caption does not replace `title:`.

The iframe loads lazily unless you pass `loading: "eager"`. Prefer `sandbox:` when the host page does not need the full iframe privileges.

## Dependencies
- Kit class `.fp-embed`, `.fp-embed__frame`, `.fp-embed__caption`.
- Tokens: `--media-radius`, `--media-outline-color`, `--surface-muted-background-color`, `--surface-muted-content-color`.
- Tailwind must see the frame and aspect-ratio class literals in `FlatPack::Embed::Component`.
