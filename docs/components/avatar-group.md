# AvatarGroup Component

Display multiple avatars in an overlapping group with an optional overflow indicator.

## Basic Usage

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: [
    {name: "John Doe", src: "https://example.com/john.jpg"},
    {name: "Jane Smith", src: "https://example.com/jane.jpg"},
    {name: "Bob Johnson"}
  ]
) %>
```

## With Maximum Display

Limit the number of visible avatars and show an overflow count:

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: users_array,
  max: 3,
  show_overflow: true
) %>
<!-- Displays: [Avatar] [Avatar] [Avatar] [+7] -->
```

## Sizes

The `size` prop is passed to all avatars in the group:

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: users,
  size: :sm
) %>
```

Available sizes: `:xs`, `:sm` (default), `:md`, `:lg`, `:xl`

## Overlap Spacing

Control how much avatars overlap:

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: users,
  overlap: :sm
) %>
```

Available overlaps: `:sm`, `:md` (default), `:lg`

## Clickable Overflow

Make the overflow count a link:

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: users,
  max: 5,
  overflow_href: "/users/all"
) %>
```

## Item Format

Each item in the `items` array can have these properties:

```ruby
{
  src: "https://example.com/avatar.jpg",  # Image URL (optional)
  name: "John Doe",                        # Name for initials (optional)
  alt: "John Doe Avatar",                  # Alt text (optional)
  initials: "JD",                          # Explicit initials (optional)
  status: :online,                         # Status indicator (optional)
  href: "/users/1"                         # Link URL (optional)
}
```

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `items` | Array | required | Array of avatar hashes |
| `max` | Integer | `5` | Maximum avatars to display |
| `size` | Symbol | `:sm` | Size passed to all avatars |
| `overlap` | Symbol | `:md` | Overlap spacing (`:sm`, `:md`, `:lg`) |
| `show_overflow` | Boolean | `true` | Show "+N" indicator for overflow |
| `overflow_href` | String | `nil` | Link for overflow indicator |
| `**system_arguments` | Hash | `{}` | Additional HTML attributes |

## Examples

### Team Members
```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: @team_members.map { |member|
    {
      name: member.name,
      src: member.avatar_url,
      href: user_path(member)
    }
  },
  size: :md,
  overlap: :lg
) %>
```

### Compact User List
```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: @participants,
  max: 3,
  size: :xs,
  overlap: :sm,
  overflow_href: participants_path
) %>
```

### With Status Indicators
```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: [
    {name: "John", status: :online},
    {name: "Jane", status: :busy},
    {name: "Bob", status: :away}
  ],
  size: :sm
) %>
```

### Hover Effects

Avatars automatically scale up on hover and gain z-index priority for better visibility:

```erb
<%= render FlatPack::AvatarGroup::Component.new(
  items: @users,
  overlap: :md,
  class: "cursor-pointer"
) %>
```
