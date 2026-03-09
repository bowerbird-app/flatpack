# Chat Components

## Purpose
Provide composable chat group UI building blocks for panels, message rendering, composer controls, and inbox rows.

## When to use
Use Chat components when building chat group interfaces with message history, typing states, attachments, and send flows.
When chat rows rendered inside `MessageList` include FlatPack chat record data attributes, consecutive rows from the same sender are grouped automatically on the client so callers do not need to pre-wrap adjacent records in `MessageGroup`.

## Class
- Primary: `FlatPack::Chat::Panel::Component`
- Related classes: `FlatPack::Chat::Layout::Component`, `FlatPack::Chat::Header::Component`, `FlatPack::Chat::MessageList::Component`, `FlatPack::Chat::MessageGroup::Component`, `FlatPack::Chat::ReceivedMessage::Component`, `FlatPack::Chat::SentMessage::Component`, `FlatPack::Chat::Composer::Component`, `FlatPack::Chat::Textarea::Component`, `FlatPack::Chat::SendButton::Component`, `FlatPack::Chat::Attachment::Component`, `FlatPack::Chat::Images::Component`, `FlatPack::Chat::ImageMessage::Component`, `FlatPack::Chat::ImageDeck::Component`, `FlatPack::Chat::InboxRow::Component`, `FlatPack::Chat::TypingIndicator::Component`

## Props
Core container props:

| name | type | default | required | description |
|---|---|---|---|---|
| `FlatPack::Chat::Layout::Component#variant` | Symbol | `:single` | no | Layout mode: `:single`, `:split`; invalid values raise `ArgumentError`. |
| `FlatPack::Chat::Panel::Component` | n/a | n/a | n/a | Slot-only container (no custom props). |

High-use interaction props:

| name | type | default | required | description |
|---|---|---|---|---|
| `FlatPack::Chat::Header::Component#title` | String | `nil` | yes | Header title text. |
| `FlatPack::Chat::Header::Component#avatar_mode` | Symbol | `:auto` | no | Avatar mode: `:auto`, `:person`, `:group`. |
| `FlatPack::Chat::MessageList::Component#stick_to_bottom` | Boolean | `true` | no | Auto-stick to latest message behavior. |
| `FlatPack::Chat::MessageList::Component#history_url` | String | `nil` | no | Endpoint for older-message loading. |
| `FlatPack::Chat::MessageList::Component#history_has_more` | Boolean | `false` | no | Enables history loader when true. |
| `FlatPack::Chat::Images::Component#carousel` | Hash | n/a | yes | Carousel-compatible hash; passed through to `FlatPack::Carousel::Component` after slide normalization. Accepts direct carousel slide hashes or attachment-like image hashes such as `href`, `thumbnail_url`, and `name`. |
| `FlatPack::Chat::Images::Component#body` | String | `nil` | no | Message copy rendered under the image carousel; blank bodies render a spacer to preserve the message shell. |
| `FlatPack::Chat::Images::Component#timestamp` | String, Time, DateTime | `nil` | no | Passed to `FlatPack::Chat::MessageMeta::Component`. |
| `FlatPack::Chat::Images::Component#reveal_actions` | Boolean | `false` | no | Enables reveal-action message behavior using the underlying sent/received message components. |
| `FlatPack::Chat::Composer::Component` | n/a | n/a | n/a | Slot-driven; defaults to chat textarea + send button when slots are omitted. |
| `FlatPack::Chat::Textarea::Component#name` | String | `"message[body]"` | no | Textarea field name. |
| `FlatPack::Chat::Textarea::Component#autogrow` | Boolean | `true` | no | Auto-resize behavior. |
| `FlatPack::Chat::Textarea::Component#submit_on_enter` | Boolean | `true` | no | Enter-to-submit behavior. |
| `FlatPack::Chat::SendButton::Component#loading` | Boolean | `false` | no | Shows sending/loading state. |
| `FlatPack::Chat::Attachment::Component#name` | String | `nil` | yes | Attachment label; blank raises `ArgumentError`. |
| `FlatPack::Chat::Attachment::Component#type` | Symbol | `:file` | no | Attachment type: `:file`, `:image`; invalid values raise `ArgumentError`. |
| `FlatPack::Chat::InboxRow::Component#chat_group_name` | String | `nil` | yes | Inbox row title; blank raises `ArgumentError`. |
| `FlatPack::Chat::InboxRow::Component#avatar_items` | Array<Hash> | `[]` | no | Participant avatars for the row. |
| `FlatPack::Chat::InboxRow::Component#max_visible_avatars` | Integer | `2` | no | Total avatar slots shown in the inbox row. For groups larger than the limit, the row reserves the last slot for a `+N` overflow avatar. |
| `FlatPack::Chat::InboxRow::Component#unread_count` | Integer | `0` | no | Positive values render the unread badge. |

## Slots
- `Layout`: `sidebar`, `panel`.
- `Panel`: `header`, `messages`, `composer`.
- `Header`: `left_meta`, `right`.
- `MessageGroup`: `avatar`, `messages`.
- `ReceivedMessage`/`SentMessage`: `attachments`, `media_attachments`, `meta` (and `actions` for sent).
- `Composer`: `left`, `center` (`textarea` alias), `right` (`actions` alias), `attachments`.
- `TypingIndicator`: optional `avatar`.

## Variants
- Layout: `:single`, `:split`.
- Directional messages: incoming/outgoing across message group and message components.
- Message state: `:sent`, `:sending`, `:failed`, `:read`.
- Attachment type: `:file`, `:image`.

## Example
```erb
<%= render FlatPack::Chat::Panel::Component.new do |panel| %>
  <% panel.header do %>
    <%= render FlatPack::Chat::Header::Component.new(title: "Design chat group", subtitle: "14 members") %>
  <% end %>

  <% panel.messages do %>
    <%= render FlatPack::Chat::MessageList::Component.new(stick_to_bottom: true) do %>
      <%= render FlatPack::Chat::MessageGroup::Component.new(
        direction: :incoming,
        show_avatar: true,
        show_name: true,
        sender_name: "Mina"
      ) do |group| %>
        <% group.with_message do %>
          <%= render FlatPack::Chat::ReceivedMessage::Component.new(state: :sent) do |message| %>
            <% message.meta do %>
              <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: Time.current, state: :sent) %>
            <% end %>
            Can we ship this by Friday?
          <% end %>
        <% end %>
      <% end %>
    <% end %>
  <% end %>

  <% panel.composer do %>
    <%= render FlatPack::Chat::Composer::Component.new %>
  <% end %>
<% end %>
```

## Image Galleries

Use `FlatPack::Chat::Images::Component` when a message should render one or more images through the carousel/lightbox path.

```erb
<%= render FlatPack::Chat::Images::Component.new(
  direction: :incoming,
  state: :sent,
  timestamp: "10:27 AM",
  body: "Sharing the latest listing photos.",
  carousel: {
    slides: [
      { href: "https://images.example.com/full-1.jpg", thumbnail_url: "https://images.example.com/thumb-1.jpg", name: "front-wheel.jpg" },
      { href: "https://images.example.com/full-2.jpg", thumbnail_url: "https://images.example.com/thumb-2.jpg", name: "rear-rack.jpg" }
    ],
    show_thumbs: true,
    show_captions: false,
    aspect_ratio: "4/3"
  }
) %>
```

`FlatPack::Chat::ImageMessage::Component` now delegates to `Chat::Images` internally for its single-image case, preserving its existing API while using the carousel/lightbox rendering path.

Multi-image attachments can be rendered with `FlatPack::Carousel::Component` inside the message media slot so attachment-heavy rows and direct `Chat::Images` calls share the same gallery behavior.

## Inbox Rows

Use `FlatPack::Chat::InboxRow::Component` for chat list entries with participant avatars, latest-message preview text, and unread state.

`max_visible_avatars` limits the total number of visible avatar slots in the row, including overflow. With the default value of `2`, a two-person thread shows two participant avatars, while a larger group shows the first participant plus a `+N` overflow avatar.

```erb
<%= render FlatPack::Chat::InboxRow::Component.new(
  chat_group_name: "Design Team",
  latest_sender: "Mina",
  latest_preview: "Uploaded revised launch copy",
  latest_at: Time.current,
  unread_count: 3,
  avatar_items: [
    { name: "Mina Cho" },
    { name: "Sam Lee" },
    { name: "Jo Kim" }
  ],
  href: "/demo/chat/demo?chat_group_id=1",
  active: true,
  turbo_frame: "chat-demo-panel"
) %>
```

## Accessibility
- Message list jump button includes explicit `aria-label`.
- Date dividers render `role="separator"` with labels.
- Outgoing/incoming reveal-actions surfaces are keyboard focusable (`role="button"`, `tabindex="0"`).
- Send button sets contextual `aria-label` (`"Send message"` / `"Sending..."`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--chat-scroll`, `flat-pack--chat-grouping`, `flat-pack--chat-textarea`, `chat-message-actions`, `flat-pack--carousel`, `flat-pack--chat-image-deck`.
- Message history loading uses `FlatPack::PaginationInfinite::Component` when configured.
