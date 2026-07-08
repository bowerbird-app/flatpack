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
| `empty_message` | String | `"No recent notifications"` | no | Empty state text. |
| `timestamp_tooltip_placement` | Symbol | `:left` | no | Tooltip placement for notification timestamps. |
| `**system_arguments` | Hash | `{}` | no | HTML attributes for the wrapper. |

## Slots
None.

## Variants
None.

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
| `:unread` | Boolean | no | Applies unread/active styling. |
| `:icon` | Symbol, String, nil | no | Optional icon passed to `FlatPack::List::Item`. |

## Timestamp behavior
Notification timestamps should be provided in ISO8601 format, for example:

```ruby
"2026-07-03T10:30:00Z"
```

Timestamps are rendered using `FlatPack::Timestamp::Component`, which displays relative time and an absolute timestamp tooltip.

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
    }
  ]
) %>
```

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
