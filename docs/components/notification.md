# Notification

## Purpose
Render a notification bell with an unread-count badge and a popover containing recent notifications.

## When to use
Use Notification in application navigation, top bars, dashboards, or account areas where users need quick access to recent notification activity.

## Class
- Primary: `FlatPack::Notification::Component`

## Props
| name | type | default | required | description |
|---|---|---|---|---|
| `notifications` | Array | `[]` | no | Recent notification data. |
| `unread_count` | Integer | `0` | no | Total unread count. Values greater than 9 render as `9+`. |
| `see_all_href` | String | `nil` | yes | Link URL for the **See all notifications** footer item. |
| `trigger_id` | String, nil | generated | no | DOM id for the bell trigger. |
| `placement` | Symbol | `:bottom` | no | Popover placement: `:top`, `:bottom`, `:left`, `:right`. |
| `bell_label` | String | `"Notifications"` | no | Accessible label for the bell button. |
| `empty_text` | String | `"No recent notifications"` | no | Empty state text. |
| `timestamp_tooltip_placement` | Symbol | `:left` | no | Tooltip placement for notification timestamps. |
| `max_height` | String or nil | `nil` | no | CSS length for the scrolling list, such as `"9rem"`. Omit it and the list keeps `max-h-96` (24rem). A class name, a blank string, or anything that is not a plain length raises `ArgumentError`. |
| `style` | Symbol | `:filled` | no | `:filled` keeps today's rounded rows, dense gap, and unread active fill. `:plain` removes that fill, the row radius, and the gap, and keeps the hover wash. Anything else raises `ArgumentError`. |
| `divider` | Boolean | `false` | no | `false` on `:filled` keeps today's dense list, including the 1px rule it already draws. `true` drops the gap so that rule is the only separation. On `:plain`, `false` draws no rule and `true` draws the List divider with no gap. Anything other than `true` or `false` raises `ArgumentError`. |
| `emphasize_unread` | Boolean | `false` | no | `false` keeps one medium title weight. `true` makes an unread title semibold in `--surface-content-color`, and its note and time semibold in `--surface-muted-content-color`. A read title, note, and time are regular weight in `--surface-muted-content-color`. A rollup counts as unread when it has unread children. Anything other than `true` or `false` raises `ArgumentError`. |
| `unread_indicator_size` | Symbol | `:sm` | no | `:sm` keeps the `fp-red-dot` mark on the icon. `:md` draws a 12px `--color-danger-background-color` circle 6px past the icon's top-left, and shifts the rollup count to that same corner without changing its size. Anything else raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the wrapper. |

## Slots
None.

## Variants
`style: :filled` is the default card row. `style: :plain` is the flush inbox row. Combine it with `divider: true`, `emphasize_unread: true`, and `unread_indicator_size: :md` when the menu should match an inbox list.

## Notification item shape
```ruby
{
  title: "New comment",
  body: "Marco commented on your post.",
  href: "/notifications/123",
  time: "2026-07-03T10:30:00Z",
  unread: true,
  icon: :bell
}
```

## Notification item keys
| key | type | required | description |
|---|---|---|---|
| `:title` | String | yes | Primary notification text. |
| `:body` | String | no | Optional secondary text. |
| `:href` | String | no | Optional notification URL. |
| `:time` | String | no | ISO8601 timestamp rendered with `FlatPack::Timestamp::Component`. |
| `:unread` | Boolean | no | On `:filled`, paints the active row fill. With `emphasize_unread: true`, it also sets the semibold unread type. A rollup parent uses its unread children for that weight and for `data-flat-pack-notification-state`, not its own `:unread` flag. |
| `:icon` | Symbol, String, nil | no | Optional icon passed to `FlatPack::List::Item`. Unread regular and nested rows add `fp-red-dot` when `unread_indicator_size` is `:sm`. `:md` paints `data-flat-pack-notification-unread-dot` instead. |
| `:rollup` | Boolean | no | When `true` and `:children` are present, renders the row as an expandable rollup parent. Missing key behaves as `false`. |
| `:children` | Array<Hash>, nil | no | Nested notification rows shown when a rollup parent is expanded. Child rows use the same shape as parent notifications. |

## Rollup behavior
- Rollup parents render with the same notification row style as regular notifications.
- Rollup parent icons render a red counter badge showing unread child count (`9+` cap).
- A caret is displayed at the end of rollup rows (`chevron-down` collapsed, rotated up when expanded).
- Rollup parent `href` is optional.
- Only one rollup group is expanded at a time.
- Nested children are rendered with left indentation to indicate hierarchy.

## Timestamp behavior
Notification timestamps should be provided in ISO8601 format, for example:

```ruby
"2026-07-03T10:30:00Z"
```

Timestamps are rendered using `FlatPack::Timestamp::Component` with `shorten_timestamp: true`, which displays compact relative time such as `20 min ago` and an absolute timestamp tooltip.

## Example
```erb
<%= render FlatPack::Notification::Component.new(
  unread_count: 12,
  see_all_href: "/notifications",
  notifications: [
    {
      title: "New comment",
      body: "Marco commented on your post.",
      href: "/notifications/1",
      time: "2026-07-03T10:30:00Z",
      unread: true,
      icon: :bell
    },
    {
      title: "Build completed",
      body: "Your export is ready to download.",
      href: "/notifications/2",
      time: "2026-07-03T09:15:00Z",
      unread: false,
      icon: :check
    },
    {
      title: "Build completed",
      body: "Your export is ready to download.",
      href: nil,
      time: "2026-07-03T09:15:00Z",
      unread: true,
      icon: :chat,
      rollup: true,
      children: [
        {
          title: "Build completed",
          body: "Your export is ready to download.",
          href: "/notifications/2",
          time: "2026-07-03T09:15:00Z",
          unread: true,
          icon: :chat
        }
      ]
    }
  ]
) %>
```

## Row hooks
Each notification row exposes stable `data-` attributes. Hosts can target them. They are part of the public API.

| attribute | values | where |
|---|---|---|
| `data-flat-pack-notification-state` | `unread` or `read` | Every row, including a nested child. A rollup parent is `unread` when any child is unread. |
| `data-flat-pack-notification-rollup` | `true` | Rollup parent rows only. |
| `data-flat-pack-notification-indicator` | `md` | Every row when `unread_indicator_size: :md`. Omitted for the default `:sm`. |
| `data-flat-pack-notification-unread-dot` | `true` | The `:md` unread dot. Omitted for `:sm`, which keeps `fp-red-dot` on the icon. |

## List height
`max_height:` limits the scrolling list. Rows that do not fit stay in that list. Scrolling the list brings them into view. The **See all notifications** link stays outside the scroller. Omit `max_height:` and the list keeps `max-h-96`.

## Accessibility
- The bell trigger is rendered as a keyboard-focusable button.
- The unread count is included in the button accessible label.
- The visual badge is hidden from assistive technology.
- The popover can be dismissed using Escape through `FlatPack::Popover::Component`.
- Timestamps render semantic `<time>` elements through `FlatPack::Timestamp::Component`.

## Dependencies
- `FlatPack::Popover::Component`
- `FlatPack::List::Component`
- `FlatPack::List::Item`
- `FlatPack::Timestamp::Component`
- `FlatPack::Shared::IconComponent`
- Stimulus controller: `flat-pack--popover`
- Stimulus controller: `flat-pack--timestamp`
- Stimulus controller: `flat-pack--icon`
