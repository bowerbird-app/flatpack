# Chat Components

## Purpose
Provide composable building blocks for chat and messaging interfaces.

## When to use
Use Chat components for conversation UIs with message lists, composer controls, typing states, and attachments.

## Class
- Primary: `FlatPack::Chat::Panel::Component`
- Related classes: `FlatPack::Chat::Layout::Component`, `FlatPack::Chat::Header::Component`, `FlatPack::Chat::MessageList::Component`, `FlatPack::Chat::MessageRecord::Component`, `FlatPack::Chat::InboxRow::Component`, `FlatPack::Chat::SentMessage::Component`, `FlatPack::Chat::ReceivedMessage::Component`, `FlatPack::Chat::SystemMessage::Component`, `FlatPack::Chat::Composer::Component`

## Props
See each sub-component section below for props and defaults.

## Slots
See each sub-component section below for supported slots.

## Variants
See message, layout, and state variants in the sections below.

## Example
Start with `Complete Example` below.

## Accessibility
See accessibility notes below for roles, labels, and keyboard interaction.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Chat Stimulus controllers (`chat_scroll_controller.js`, `chat_textarea_controller.js`, `chat_sender_controller.js`).

A comprehensive messaging UI component system for building modern chat interfaces in Rails applications.

## Overview

The Chat component system provides everything you need to build Slack/Intercom-style messaging interfaces. It includes message bubbles with various states, typing indicators, file attachments, message grouping, and a smart composer with auto-growing textarea.

## Components

### Layout Components

#### Chat::Layout::Component

Container component for organizing chat interfaces.

**Props:**
- `variant`: `:single` (default) | `:split` - Layout style
- `**system_arguments` - Standard HTML attributes

**Slots:**
- `sidebar` - Optional sidebar area
- `panel` - Main chat panel

**Example:**
```erb
<%= render FlatPack::Chat::Layout::Component.new(variant: :split) do |layout| %>
  <% layout.sidebar do %>
    <!-- Conversation list -->
  <% end %>
  
  <% layout.panel do %>
    <%= render FlatPack::Chat::Panel::Component.new do |panel| %>
      <!-- Chat content -->
    <% end %>
  <% end %>
<% end %>
```

#### Chat::Panel::Component

Organizes chat panel with header, messages, and composer sections.

**Slots:**
- `header` - Chat header area
- `messages` - Scrollable messages area
- `composer` - Message input area

**Example:**
```erb
<%= render FlatPack::Chat::Panel::Component.new do |panel| %>
  <% panel.header do %>
    <div class="p-4">
      <h2 class="font-semibold">Design Team</h2>
    </div>
  <% end %>
  
  <% panel.messages do %>
    <%= render FlatPack::Chat::MessageList::Component.new do %>
      <!-- Messages go here -->
    <% end %>
  <% end %>
  
  <% panel.composer do %>
    <%= render FlatPack::Chat::Composer::Component.new %>
  <% end %>
<% end %>
```

#### Chat::Header::Component

Reusable header for chat panels with optional back button, person avatar, chat group avatars, and right-side actions.

**Props:**
- `title`: (required) - Header title (person or chat group name)
- `subtitle`: String - Secondary info (presence, member count, etc.)
- `back_href`: String - Optional destination for back button
- `back_label`: String - Back button text (`"Back"` by default)
- `content_url`: String - Optional link for avatar + title/subtitle area (for example, chat group settings)
- `avatar_mode`: `:auto` (default) | `:person` | `:group`
- `person_avatar`: Hash - Props forwarded to `FlatPack::Avatar::Component`
- `group_avatars`: Array - Items for `FlatPack::AvatarGroup::Component`
- `group_max`: Number - Max visible chat group avatars before `+n` overflow (default: `5`)
- `group_size`: `:sm` | `:md` | `:lg` (default: `:sm`)
- `**system_arguments`

**Slots:**
- `left_meta` - Optional extra text under the subtitle
- `right` - Right-side actions (buttons/menus)

**Example:**
```erb
<%= render FlatPack::Chat::Header::Component.new(
  title: "Design Team",
  subtitle: "14 members",
  back_href: chat_groups_path,
  content_url: chat_group_settings_path(@chat_group),
  group_avatars: @participants,
  group_max: 5
) do |header| %>
  <% header.right do %>
    <%= render FlatPack::Button::Component.new(icon: "search", icon_only: true, style: :ghost, size: :sm) %>
  <% end %>
<% end %>
```

### Message List Components

#### Chat::MessageList::Component

Scrollable container for messages with auto-scroll and "Jump to latest" button.

**Props:**
- `stick_to_bottom`: `true` (default) | `false` - Auto-scroll to bottom
- `history_url`: String - Endpoint used to fetch older messages when scrolling up
- `history_has_more`: `false` (default) | `true` - Whether more history exists
- `history_limit`: Number | `nil` - Optional batch size sent on each history request
- `history_cursor_selector`: String - Selector used to find the current oldest message cursor
- `history_cursor_param`: String - Query param name for cursor (default: `before_id`)
- `history_limit_param`: String - Query param name for batch size (default: `limit`)
- `history_loading_text`: String - Loading copy shown while fetching older messages
- `**system_arguments`

**Features:**
- Auto-scrolls to bottom on initial load
- Shows "Jump to latest" button when scrolled up
- Smooth scrolling
- Stimulus controller integration
- Optional infinite history loading when the top sentinel enters view

**Example:**
```erb
<%= render FlatPack::Chat::MessageList::Component.new(
  stick_to_bottom: true,
  history_url: chat_group_messages_path(@chat_group),
  history_has_more: @has_more_history,
  history_limit: 20
) do %>
  <%= render FlatPack::Chat::DateDivider::Component.new(label: "Today") %>

  <div data-pagination-content>
    <% @messages.each do |message| %>
      <div data-pagination-cursor="<%= message.id %>">
        <!-- message markup -->
      </div>
    <% end %>
  </div>
<% end %>
```

#### Chat::DateDivider::Component

Displays a date separator between messages.

**Props:**
- `label`: (required) - Date label text
- `**system_arguments`

**Example:**
```erb
<%= render FlatPack::Chat::DateDivider::Component.new(label: "Today") %>
<%= render FlatPack::Chat::DateDivider::Component.new(label: "Yesterday") %>
<%= render FlatPack::Chat::DateDivider::Component.new(label: "December 15, 2024") %>
```

#### Chat::MessageGroup::Component

Groups consecutive messages from the same sender.

**Props:**
- `direction`: `:incoming` (default) | `:outgoing`
- `show_avatar`: `true` (default) | `false`
- `show_name`: `false` (default) | `true`
- `sender_name`: String - Name of sender
- `**system_arguments`

**Slots:**
- `avatar` - Avatar component
- `messages` (many) - Message components

**Example:**
```erb
<%= render FlatPack::Chat::MessageGroup::Component.new(
  direction: :incoming,
  show_avatar: true,
  show_name: true,
  sender_name: "Alice Johnson"
) do |group| %>
  <% group.with_avatar do %>
    <%= render FlatPack::Avatar::Component.new(
      name: "Alice Johnson",
      src: "/images/alice.jpg"
    ) %>
  <% end %>
  
  <% group.with_message do %>
    <%= render FlatPack::Chat::ReceivedMessage::Component.new do %>
      First message in the group
    <% end %>
  <% end %>
  
  <% group.with_message do %>
    <%= render FlatPack::Chat::ReceivedMessage::Component.new do %>
      Second message in the group
    <% end %>
  <% end %>
<% end %>
```

### Message Components

#### Chat::MessageRecord::Component

Model-backed message row component that renders message group, bubble, avatar, and metadata together.

Use this when you have a persisted message object and want to avoid custom partials for incoming/outgoing logic.

**Props:**
- `record`: message-like object (optional if explicit fields are passed)
- `body`: String - falls back to `record.body`
- `sender_name`: String - falls back to `record.sender_name`
- `timestamp`: Time/String - falls back to `record.created_at`
- `state`: `:sent` (default fallback) | `:sending` | `:failed` | `:read`
- `direction`: `:incoming` | `:outgoing` (optional override; inferred from `record.outgoing?` or `sender_name == "You"`)
- `show_avatar`: `true`/`false` (defaults to `true` for incoming, `false` for outgoing)
- `show_name`: `true`/`false` (defaults to `true` for incoming, `false` for outgoing)
- `**system_arguments`

**Example:**
```erb
<%= render FlatPack::Chat::MessageRecord::Component.new(record: message) %>

<%= render FlatPack::Chat::MessageRecord::Component.new(
  body: "Can you confirm launch timing?",
  sender_name: "Mina",
  timestamp: Time.current,
  state: :sent
) %>
```

#### Chat::InboxRow::Component

Reusable inbox row for chat group sidebars. It composes avatar clusters, latest preview text, timestamp, and unread count into one list item.

**Props:**
- `chat_group_name`: String (required)
- `avatar_items`: Array - forwarded to `FlatPack::AvatarGroup::Component`
- `latest_sender`: String - optional sender label used in preview
- `latest_preview`: String - optional preview copy
- `latest_at`: Time/String - optional trailing time label
- `unread_count`: Integer - optional unread badge count
- `href`: String - optional link target
- `active`: `true` | `false` (default: `false`)
- `turbo_frame`: String - optional `data-turbo-frame` forwarding for linked rows

**Example:**
```erb
<%= render FlatPack::List::Component.new(spacing: :dense, selectable: true) do %>
  <%= render FlatPack::Chat::InboxRow::Component.new(
    chat_group_name: "Design Team",
    latest_sender: "Mina",
    latest_preview: "Uploaded revised launch copy",
    latest_at: Time.current,
    unread_count: 3,
    avatar_items: [
      {name: "Mina Cho", initials: "MC"},
      {name: "Sam Lee", initials: "SL"}
    ],
    href: demo_chat_demo_path(chat_group_id: 1),
    turbo_frame: "chat-demo-panel",
    active: true
  ) %>
<% end %>
```

#### Chat::ReceivedMessage::Component

Incoming message bubble with optional attachments and meta.

**Props:**
- `state`: `:sent` (default) | `:sending` | `:failed` | `:read`
- `reveal_actions`: `false` (default) | `true` (reveals timestamp tray)
- `timestamp`: Time object or string
- `**system_arguments`

**Slots:**
- Block content - Message text
- `attachments` (many) - Attachment components
- `meta` - MessageMeta component

#### Chat::SentMessage::Component

Outgoing message bubble with optional slide-to-reveal actions.

**Props:**
- `state`: `:sent` (default) | `:sending` | `:failed` | `:read`
- `reveal_actions`: `false` (default) | `true`
- `timestamp`: Time object or string
- `**system_arguments`

**Slots:**
- Block content - Message text
- `attachments` (many) - Attachment components
- `meta` - MessageMeta component
- `actions` - Optional custom action controls in reveal tray

#### Chat::SystemMessage::Component

Centered timeline-style system event row.

**Example:**
```erb
<%= render FlatPack::Chat::ReceivedMessage::Component.new do |message| %>
  This is a message from someone else.
  <% message.with_meta do %>
    <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: Time.current, state: :sent) %>
  <% end %>
<% end %>

<%= render FlatPack::Chat::SentMessage::Component.new(state: :read) do |message| %>
  This is my message that has been read.
  <% message.with_meta do %>
    <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: Time.current, state: :read) %>
  <% end %>
<% end %>

<%= render FlatPack::Chat::SystemMessage::Component.new do %>
  Alice joined the conversation
<% end %>
```

#### Chat::MessageMeta::Component

Displays timestamp, edited status, and delivery state indicators.

**Props:**
- `timestamp`: Time object or string
- `state`: `:sent` (default) | `:sending` | `:failed` | `:read`
- `edited`: `false` (default) | `true`
- `**system_arguments`

**Example:**
```erb
<%= render FlatPack::Chat::MessageMeta::Component.new(
  timestamp: Time.current,
  state: :read,
  edited: true
) %>
```

### Composer Components

#### Chat::Composer::Component

Message input area with flexible left, center, and right regions.

**Slots:**
- `left` - Optional controls shown before the input
- `center` - Main input area (usually `Chat::Textarea`)
- `right` - Action buttons shown after the input
- `attachments` - Attachment preview area

**Default Behavior:**
If no slots provided, renders a default textarea in center and send button in right.

**Example:**
```erb
<!-- Default composer -->
<%= render FlatPack::Chat::Composer::Component.new %>

<!-- Custom composer -->
<%= render FlatPack::Chat::Composer::Component.new do |composer| %>
  <% composer.left do %>
    <%= render FlatPack::Button::Component.new(text: "Attach", style: :ghost, size: :sm) %>
  <% end %>

  <% composer.center do %>
    <%= render FlatPack::Chat::Textarea::Component.new(
      placeholder: "Type your message...",
      autogrow: true,
      submit_on_enter: true
    ) %>
  <% end %>

  <% composer.right do %>
    <%= render FlatPack::Chat::SendButton::Component.new(loading: false) %>
  <% end %>
<% end %>
```

#### Chat::Textarea::Component

Auto-growing textarea with Enter to submit.

**Props:**
- `name`: `"message[body]"` (default) - Form field name
- `placeholder`: `"Type a message..."` (default)
- `autogrow`: `true` (default) | `false`
- `submit_on_enter`: `true` (default) | `false`
- `**system_arguments`

**Features:**
- Auto-expands as user types
- Enter submits form
- Shift+Enter adds newline
- Max height constraint

**Example:**
```erb
<%= render FlatPack::Chat::Textarea::Component.new(
  name: "message[body]",
  placeholder: "Type a message...",
  autogrow: true,
  submit_on_enter: true
) %>
```

#### Chat::SendButton::Component

Send button with loading state.

**Props:**
- `loading`: `false` (default) | `true`
- `disabled`: `false` (default) | `true`
- `**system_arguments`

**Example:**
```erb
<%= render FlatPack::Chat::SendButton::Component.new(loading: false) %>
<%= render FlatPack::Chat::SendButton::Component.new(loading: true) %>
```

#### Optimistic Send (JavaScript)

Use the `flat-pack--chat-sender` Stimulus controller on your composer form to append outgoing bubbles immediately without a page reload.

**Form wiring:**
```erb
<%= form_with url: messages_path, method: :post, local: true,
  data: {
    controller: "flat-pack--chat-sender",
    action: "submit->flat-pack--chat-sender#submit flat-pack:picker:confirm@document->flat-pack--chat-sender#handlePickerConfirm",
    flat_pack__chat_sender_thread_selector_value: "[data-flat-pack--chat-scroll-target='messages']",
    flat_pack__chat_sender_optimistic_endpoint_value: "/messages/preview",
    flat_pack__chat_sender_composition_mode_value: "separate",
    flat_pack__chat_sender_picker_ids_value: ["chat-picker-images", "chat-picker-files"]
  } do %>
  <%= render FlatPack::Chat::Composer::Component.new %>
<% end %>
```

`composition_mode` controls how mixed text + attachments are sent to your backend:
- `"separate"` (default): text and each attachment are separate chat items.
- `"combined"`: text + attachments are sent as one chat item payload.

Picker event scoping options:
- `flat_pack__chat_sender_picker_ids_value`: preferred. Array of picker ids this sender should accept.
- `flat_pack__chat_sender_picker_scope_value`: optional scope label matched against `event.detail.context.scope` (or `context.target` for backwards compatibility).

**How delivery is pluggable:**
- The controller dispatches `flat-pack:chat:send` on submit.
- The controller dispatches `flat-pack:chat:render-optimistic` before appending the optimistic message bubble.
- Your app can call `event.detail.respondWith(promise)` to plug in any async backend flow (DB/API/ActionCable/etc).
- Resolve with `{ html: "..." }` to replace the optimistic bubble with server-rendered HTML, or `{ body:, timestamp:, state: }` for lightweight confirmation.
- Reject to mark the optimistic message as failed.

**How optimistic rendering is pluggable:**
- Listen for `flat-pack:chat:render-optimistic`.
- Call `event.detail.respondWith(elementOrHtml)` to provide your own optimistic message element.
- If no response is provided, FlatPack uses the built-in optimistic renderer.
- If `flat_pack__chat_sender_optimistic_endpoint_value` is provided, FlatPack will request `{ html }` from that endpoint before falling back to the built-in renderer.

**Optimistic endpoint contract (optional):**
- Method: `POST` (uses `flat_pack__chat_sender_method_value`, default `post`)
- Request body: `{ message: payload }`
- Response JSON: `{ html: "<div>...</div>" }`
- If `html` contains multiple top-level elements, FlatPack wraps them in a temporary container so nothing is dropped.

**Optimistic render override example:**
```js
document.addEventListener("flat-pack:chat:render-optimistic", (event) => {
  const { payload } = event.detail
  const wrapper = document.createElement("div")
  wrapper.className = "flex justify-end"
  wrapper.textContent = payload.body || "Sending attachment..."
  event.detail.respondWith(wrapper)
})
```

**Host app example:**
```js
document.addEventListener("flat-pack:chat:send", (event) => {
  event.detail.respondWith(
    fetch("/messages", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ message: event.detail.payload })
    }).then((response) => response.json())
  )
})
```

### Utility Components

#### Chat::TypingIndicator::Component

Animated typing indicator with optional avatar.

**Props:**
- `label`: `"Someone is typing"` (default)
- `**system_arguments`

**Slots:**
- `avatar` - Avatar component

**Example:**
```erb
<%= render FlatPack::Chat::TypingIndicator::Component.new(
  label: "Alice is typing"
) do |indicator| %>
  <% indicator.with_avatar do %>
    <%= render FlatPack::Avatar::Component.new(name: "Alice") %>
  <% end %>
<% end %>
```

#### Chat::Attachment::Component

File or image attachment preview in messages.

**Props:**
- `type`: `:file` (default) | `:image`
- `name`: (required) - File name
- `meta`: String - File size or description
- `href`: URL - Download/view link
- `thumbnail_url`: URL - For image type
- `**system_arguments`

**Example:**
```erb
<!-- File attachment -->
<%= render FlatPack::Chat::Attachment::Component.new(
  type: :file,
  name: "quarterly-report.pdf",
  meta: "2.4 MB",
  href: "/files/quarterly-report.pdf"
) %>

<!-- Image attachment -->
<%= render FlatPack::Chat::Attachment::Component.new(
  type: :image,
  name: "screenshot.png",
  thumbnail_url: "/images/screenshot-thumb.png",
  href: "/images/screenshot.png"
) %>
```

## Complete Example

Here's a complete chat interface example:

```erb
<div style="height: 600px;">
  <%= render FlatPack::Chat::Panel::Component.new do |panel| %>
    <% panel.header do %>
      <%= render FlatPack::Chat::Header::Component.new(
        title: "Design Team",
        subtitle: "3 members",
        back_href: chat_groups_path,
        group_avatars: [
          { name: "Alice", src: "/images/alice.jpg" },
          { name: "Bob", src: "/images/bob.jpg" },
          { name: "Carol", src: "/images/carol.jpg" }
        ],
        group_max: 3
      ) %>
    <% end %>
    
    <% panel.messages do %>
      <%= render FlatPack::Chat::MessageList::Component.new(stick_to_bottom: true) do %>
        <%= render FlatPack::Chat::DateDivider::Component.new(label: "Today") %>
        
        <!-- Incoming messages -->
        <%= render FlatPack::Chat::MessageGroup::Component.new(
          direction: :incoming,
          show_avatar: true,
          show_name: true,
          sender_name: "Alice Johnson"
        ) do |group| %>
          <% group.with_avatar do %>
            <%= render FlatPack::Avatar::Component.new(name: "Alice Johnson") %>
          <% end %>
          
          <% group.with_message do %>
            <%= render FlatPack::Chat::ReceivedMessage::Component.new do |message| %>
              <% message.with_meta do %>
                <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: 2.hours.ago, state: :sent) %>
              <% end %>
              Hey team! I've finished the new design mockups.
            <% end %>
          <% end %>
          
          <% group.with_message do %>
            <%= render FlatPack::Chat::ReceivedMessage::Component.new do |message| %>
              Take a look and let me know what you think!

              <% message.with_meta do %>
                <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: 2.hours.ago, state: :sent) %>
              <% end %>
              
              <% message.with_attachment do %>
                <%= render FlatPack::Chat::Attachment::Component.new(
                  type: :image,
                  name: "design-v2.png",
                  thumbnail_url: "/images/design-thumb.png",
                  href: "/images/design-v2.png"
                ) %>
              <% end %>
            <% end %>
          <% end %>
        <% end %>
        
        <!-- Outgoing messages -->
        <%= render FlatPack::Chat::MessageGroup::Component.new(
          direction: :outgoing,
          show_avatar: false
        ) do |group| %>
          <% group.with_message do %>
            <%= render FlatPack::Chat::SentMessage::Component.new(state: :read) do |message| %>
              <% message.with_meta do %>
                <%= render FlatPack::Chat::MessageMeta::Component.new(timestamp: 1.hour.ago, state: :read) %>
              <% end %>
              Looks great! I really like the new color scheme.
            <% end %>
          <% end %>
        <% end %>
        
        <!-- Typing indicator -->
        <%= render FlatPack::Chat::TypingIndicator::Component.new(
          label: "Alice is typing"
        ) do |indicator| %>
          <% indicator.with_avatar do %>
            <%= render FlatPack::Avatar::Component.new(name: "Alice") %>
          <% end %>
        <% end %>
      <% end %>
    <% end %>
    
    <% panel.composer do %>
      <%= render FlatPack::Chat::Composer::Component.new %>
    <% end %>
  <% end %>
</div>
```

## Styling

All chat components use FlatPack's design system:
- Dedicated chat CSS variables for theming (`--chat-*`)
- Shared semantic variables for brand/feedback (`--color-*`)
- Tailwind utility classes
- Proper focus states
- Dark mode support
- Responsive design

## Stimulus Controllers

### chat_scroll_controller.js

Attached to `Chat::MessageList::Component`:
- Auto-scrolls to bottom on load
- Shows/hides "Jump to latest" button
- Smooth scrolling behavior

### chat_textarea_controller.js

Attached to `Chat::Textarea::Component`:
- Auto-grow as user types
- Enter to submit (Shift+Enter for newline)
- Max height constraint

## Accessibility

All components include proper ARIA attributes:
- `aria-label` on buttons and indicators
- `role="separator"` on date dividers
- Semantic HTML structure
- Keyboard navigation support

## Integration with Avatar Components

Chat components are designed to work seamlessly with `FlatPack::Avatar::Component` and `FlatPack::AvatarGroup::Component`:

```erb
<!-- Single avatar in message group -->
<% group.with_avatar do %>
  <%= render FlatPack::Avatar::Component.new(
    name: "Alice Johnson",
    src: "/images/alice.jpg",
    status: :online,
    size: :sm
  ) %>
<% end %>

<!-- Avatar group in chat header -->
<%= render FlatPack::AvatarGroup::Component.new(
  items: @participants,
  max: 5,
  size: :sm
) %>
```

## Best Practices

1. **Group consecutive messages** from the same sender using `MessageGroup`
2. **Use date dividers** to break up conversations by day
3. **Show avatars** only for incoming messages in 1:1 chats
4. **Include timestamps** in message metadata
5. **Handle loading states** with the SendButton `loading` prop
6. **Display typing indicators** when other users are composing
7. **Show attachment previews** inline with messages
8. **Use system messages** for events like joins/leaves
9. **Implement proper error handling** with the `:failed` state
10. **Consider accessibility** with proper ARIA labels

## Common Patterns

### 1:1 Chat
- Show avatar for incoming messages only
- Use compact message grouping
- Display read receipts

### Group Chat
- Show avatars for all messages
- Include sender names
- Use AvatarGroup in header

### Support Chat
- Use system messages for status updates
- Show typing indicators
- Include file attachments

### Real-time Updates
- Use Stimulus controllers for auto-scroll
- Update message states via Turbo Streams
- Animate typing indicators
