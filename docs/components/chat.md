# Chat Components

## Purpose
Provide composable chat group UI building blocks for panels, message rendering, composer controls, and inbox rows.

## When to use
Use Chat components when building chat group interfaces with message history, typing states, attachments, and send flows.

## Class
- Primary: `FlatPack::Chat::Panel::Component`
- Related classes: `FlatPack::Chat::Layout::Component`, `FlatPack::Chat::Header::Component`, `FlatPack::Chat::MessageList::Component`, `FlatPack::Chat::MessageRecord::Component`, `FlatPack::Chat::Composer::Component`, `FlatPack::Chat::Textarea::Component`, `FlatPack::Chat::SendButton::Component`, `FlatPack::Chat::Attachment::Component`, `FlatPack::Chat::ImageDeck::Component`, `FlatPack::Chat::InboxRow::Component`, `FlatPack::Chat::TypingIndicator::Component`

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
| `FlatPack::Chat::MessageRecord::Component#record` | Object | `nil` | no | Message-like record source for body/sender/state/timestamp/attachments. |
| `FlatPack::Chat::MessageRecord::Component#state` | Symbol | inferred / `:sent` | no | Message state: `:sent`, `:sending`, `:failed`, `:read`. |
| `FlatPack::Chat::MessageRecord::Component#direction` | Symbol | inferred | no | `:incoming` or `:outgoing`. |
| `FlatPack::Chat::Composer::Component` | n/a | n/a | n/a | Slot-driven; defaults to chat textarea + send button when slots are omitted. |
| `FlatPack::Chat::Textarea::Component#name` | String | `"message[body]"` | no | Textarea field name. |
| `FlatPack::Chat::Textarea::Component#autogrow` | Boolean | `true` | no | Auto-resize behavior. |
| `FlatPack::Chat::Textarea::Component#submit_on_enter` | Boolean | `true` | no | Enter-to-submit behavior. |
| `FlatPack::Chat::SendButton::Component#loading` | Boolean | `false` | no | Shows sending/loading state. |
| `FlatPack::Chat::Attachment::Component#name` | String | `nil` | yes | Attachment label; blank raises `ArgumentError`. |
| `FlatPack::Chat::Attachment::Component#type` | Symbol | `:file` | no | Attachment type: `:file`, `:image`; invalid values raise `ArgumentError`. |

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
      <%= render FlatPack::Chat::MessageRecord::Component.new(
        body: "Can we ship this by Friday?",
        sender_name: "Mina",
        direction: :incoming,
        state: :sent,
        timestamp: Time.current
      ) %>
    <% end %>
  <% end %>

  <% panel.composer do %>
    <%= render FlatPack::Chat::Composer::Component.new %>
  <% end %>
<% end %>
```

## Accessibility
- Message list jump button includes explicit `aria-label`.
- Date dividers render `role="separator"` with labels.
- Outgoing/incoming reveal-actions surfaces are keyboard focusable (`role="button"`, `tabindex="0"`).
- Send button sets contextual `aria-label` (`"Send message"` / `"Sending..."`).

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--chat-scroll`, `flat-pack--chat-textarea`, `chat-message-actions`, `flat-pack--chat-image-deck`.
- Message history loading uses `FlatPack::PaginationInfinite::Component` when configured.
