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
| `style` | Symbol | `:filled` | no | Passed to `FlatPack::List`. `:filled` keeps the rounded active row. `:plain` removes the active fill, the radius, and the gap, and keeps the hover wash. Anything else raises `ArgumentError`. |
| `divider` | Boolean | `false` | no | On `:plain`, `true` draws the List rule and `false` draws none. `:filled` always draws that rule. The rule is flush with the row. Anything other than `true` or `false` raises `ArgumentError`. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the wrapper. |

## Slots
Pass a block to render each row's content. The block is called once per notification, including a nested rollup child, and receives that notification hash. FlatPack keeps the row wrapper, the hover wash, and the link when `href` is set. A rollup parent also keeps its toggle. Omit the block and the component renders the default icon, title, note, time, and the small `fp-red-dot`.

## Variants
`style: :filled` is the default card row. The 1px list rule sits against the active fill. `style: :plain` is the flush row. Pass `divider: true` when that row should show the rule. Style the title, note, time, and dot in the block.

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
| `:unread` | Boolean | no | On `:filled`, paints the active row fill. The default icon adds `fp-red-dot` when this is true. A host block decides its own unread treatment. |
| `:icon` | Symbol, String, nil | no | Optional icon passed to `FlatPack::List::Item` when no block is given. Unread rows add `fp-red-dot` on that icon. |
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

## Host row
```erb
<%= render FlatPack::Notification::Component.new(
  see_all_href: notifications_path,
  notifications: notifications,
  style: :plain,
  divider: true
) do |notification| %>
  <span class="font-semibold"><%= notification[:title] %></span>
<% end %>
```

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
