# Chat Components

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

### Message List Components

#### Chat::MessageList::Component

Scrollable container for messages with auto-scroll and "Jump to latest" button.

**Props:**
- `stick_to_bottom`: `true` (default) | `false` - Auto-scroll to bottom
- `**system_arguments`

**Features:**
- Auto-scrolls to bottom on initial load
- Shows "Jump to latest" button when scrolled up
- Smooth scrolling
- Stimulus controller integration

**Example:**
```erb
<%= render FlatPack::Chat::MessageList::Component.new(stick_to_bottom: true) do %>
  <%= render FlatPack::Chat::DateDivider::Component.new(label: "Today") %>
  
  <%= render FlatPack::Chat::MessageGroup::Component.new(
    direction: :incoming,
    sender_name: "Alice"
  ) do |group| %>
    <% group.with_avatar do %>
      <%= render FlatPack::Avatar::Component.new(name: "Alice") %>
    <% end %>
    
    <% group.with_message do %>
      <%= render FlatPack::Chat::Message::Component.new(
        direction: :incoming,
        timestamp: Time.current
      ) do %>
        Hello! How are you?
      <% end %>
    <% end %>
  <% end %>
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
    <%= render FlatPack::Chat::Message::Component.new(direction: :incoming) do %>
      First message in the group
    <% end %>
  <% end %>
  
  <% group.with_message do %>
    <%= render FlatPack::Chat::Message::Component.new(direction: :incoming) do %>
      Second message in the group
    <% end %>
  <% end %>
<% end %>
```

### Message Components

#### Chat::Message::Component

Individual message bubble with content, attachments, and metadata.

**Props:**
- `direction`: `:incoming` (default) | `:outgoing`
- `variant`: `:default` (default) | `:system`
- `state`: `:sent` (default) | `:sending` | `:failed` | `:read`
- `timestamp`: Time object or string
- `edited`: `false` (default) | `true`
- `**system_arguments`

**Slots:**
- Block content - Message text
- `attachments` (many) - Attachment components
- `meta` - MessageMeta component

**States:**
- `:sent` - Default successful delivery
- `:sending` - Reduced opacity, shows "Sending..."
- `:failed` - Red border, alert icon
- `:read` - Blue check marks

**Example:**
```erb
<!-- Incoming message -->
<%= render FlatPack::Chat::Message::Component.new(
  direction: :incoming,
  timestamp: Time.current
) do %>
  This is a message from someone else.
<% end %>

<!-- Outgoing message -->
<%= render FlatPack::Chat::Message::Component.new(
  direction: :outgoing,
  state: :read,
  timestamp: Time.current
) do %>
  This is my message that has been read.
<% end %>

<!-- Message with metadata -->
<%= render FlatPack::Chat::Message::Component.new(
  direction: :outgoing,
  edited: true
) do |message| %>
  Edited message content
  
  <% message.with_meta do %>
    <%= render FlatPack::Chat::MessageMeta::Component.new(
      timestamp: Time.current,
      edited: true,
      state: :read
    ) %>
  <% end %>
<% end %>

<!-- System message -->
<%= render FlatPack::Chat::Message::Component.new(
  variant: :system
) do %>
  Alice joined the conversation
<% end %>

<!-- Message with attachments -->
<%= render FlatPack::Chat::Message::Component.new(
  direction: :incoming
) do |message| %>
  Check out this file!
  
  <% message.with_attachment do %>
    <%= render FlatPack::Chat::Attachment::Component.new(
      type: :file,
      name: "design-specs.pdf",
      meta: "2.4 MB",
      href: "/files/design-specs.pdf"
    ) %>
  <% end %>
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

Message input area with textarea and actions.

**Slots:**
- `textarea` - Custom textarea component
- `actions` - Custom action buttons
- `attachments` - Attachment preview area

**Default Behavior:**
If no slots provided, renders default textarea and send button.

**Example:**
```erb
<!-- Default composer -->
<%= render FlatPack::Chat::Composer::Component.new %>

<!-- Custom composer -->
<%= render FlatPack::Chat::Composer::Component.new do |composer| %>
  <% composer.with_textarea do %>
    <%= render FlatPack::Chat::Textarea::Component.new(
      placeholder: "Type your message...",
      autogrow: true,
      submit_on_enter: true
    ) %>
  <% end %>
  
  <% composer.with_actions do %>
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
      <div class="p-4 flex items-center justify-between">
        <div>
          <h2 class="font-semibold text-[var(--color-foreground)]">Design Team</h2>
          <p class="text-sm text-[var(--color-muted-foreground)]">3 members</p>
        </div>
        <%= render FlatPack::AvatarGroup::Component.new(
          items: [
            { name: "Alice", src: "/images/alice.jpg" },
            { name: "Bob", src: "/images/bob.jpg" },
            { name: "Carol", src: "/images/carol.jpg" }
          ],
          max: 3,
          size: :sm
        ) %>
      </div>
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
            <%= render FlatPack::Chat::Message::Component.new(
              direction: :incoming,
              timestamp: 2.hours.ago
            ) do %>
              Hey team! I've finished the new design mockups.
            <% end %>
          <% end %>
          
          <% group.with_message do %>
            <%= render FlatPack::Chat::Message::Component.new(
              direction: :incoming,
              timestamp: 2.hours.ago
            ) do |message| %>
              Take a look and let me know what you think!
              
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
            <%= render FlatPack::Chat::Message::Component.new(
              direction: :outgoing,
              state: :read,
              timestamp: 1.hour.ago
            ) do %>
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
- CSS variables for theming (`--color-*`)
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
