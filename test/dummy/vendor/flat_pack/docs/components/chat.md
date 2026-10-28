# Chat Components

## Purpose
Provide composable chat group UI building blocks for panels, message rendering, composer controls, and inbox rows.

## When to use
Use Chat components when building chat group interfaces with message history, typing states, attachments, and send flows.
When `MessageRecord` rows are rendered inside `MessageList`, consecutive rows from the same sender are grouped automatically on the client so callers do not need to pre-wrap adjacent records in `MessageGroup`.

## Class
- Primary: `FlatPack::Chat::Panel::Component`
- Related classes: `FlatPack::Chat::Layout::Component`, `FlatPack::Chat::Header::Component`, `FlatPack::Chat::MessageList::Component`, `FlatPack::Chat::MessageRecord::Component`, `FlatPack::Chat::Composer::Component`, `FlatPack::Chat::Textarea::Component`, `FlatPack::Chat::SendButton::Component`, `FlatPack::Chat::Attachment::Component`, `FlatPack::Chat::Images::Component`, `FlatPack::Chat::ImageDeck::Component`, `FlatPack::Chat::InboxRow::Component`, `FlatPack::Chat::TypingIndicator::Component`

## Props
Core container props:

| name | type | default | required | description |
|---|---|---|---|---|
| `FlatPack::Chat::Layout::Component#variant` | Symbol | `:single` | no | Layout mode: `:single`, `:split`; invalid values raise `ArgumentError`. |
| `FlatPack::Chat::Layout::Component#split_breakpoint` | Symbol | `:sm` | no | Width at which `:split` stops stacking and becomes two columns: `:sm` (640px), `:md` (768px), `:lg` (1024px); invalid values raise `ArgumentError`. |
| `FlatPack::Chat::Layout::Component#sidebar_width` | String | `"clamp(12rem, 30%, 16rem)"` | no | CSS grid track for the sidebar column. Accepts a length, `auto`, `min-content`, `max-content`, a CSS variable, or `minmax()` / `clamp()` / `fit-content()`; anything else raises `ArgumentError`. |
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
| `FlatPack::Chat::Images::Component#carousel` | Hash | n/a | yes | Carousel-compatible hash; passed through to `FlatPack::Carousel::Component` after slide normalization. |
| `FlatPack::Chat::Composer::Component` | n/a | n/a | n/a | Slot-driven; defaults to chat textarea + send button when slots are omitted. |
| `FlatPack::Chat::Textarea::Component#name` | String | `"message[body]"` | no | Textarea field name. |
| `FlatPack::Chat::Textarea::Component#autogrow` | Boolean | `true` | no | Auto-resize behavior. |
| `FlatPack::Chat::Textarea::Component#submit_on_enter` | Boolean | `true` | no | Enter-to-submit behavior. |
| `FlatPack::Chat::SendButton::Component#loading` | Boolean | `false` | no | Shows sending/loading state. |
| `FlatPack::Chat::Attachment::Component#name` | String | `nil` | yes | Attachment label; blank raises `ArgumentError`. |
| `FlatPack::Chat::Attachment::Component#type` | Symbol | `:file` | no | Attachment type: `:file`, `:image`; invalid values raise `ArgumentError`. |
| `FlatPack::Chat::InboxRow::Component#chat_group_name` | String | none | yes | Conversation name. |
| `FlatPack::Chat::InboxRow::Component#unread_count` | Integer | `0` | no | Unread count. Positive values render a primary badge with tabular nums. Rows do not clip trailing chrome (`overflow-hidden` is not set). |

## Slots
- `Layout`: `sidebar`, `panel`.
- `Panel`: `header`, `right_header`, `right_header_mobile`, `messages`, `composer`. `right_header` and `right_header_mobile` are optional. When either is present the header bar is a row: `flex items-center`. `header` is `min-w-0 flex-1` and stays a block, so caller content still fills that part and truncates. Each right part is `shrink-0 w-min items-center justify-end`. The row's `items-center` lines the title block up with the actions. Omit both right slots and the header markup stays a single wrapper. The bar does not add padding. A parent can restyle the parts with `data-flat-pack-chat-panel-part="header"`, `data-flat-pack-chat-panel-part="right-header"`, and `data-flat-pack-chat-panel-part="right-header-mobile"`. A right part with no `header` also has `ml-auto`. Because the part is `w-min` and does not shrink, its content must not wrap: use `whitespace-nowrap`, icon buttons, and badges. Use `right_header` for actions beside the panel `header` slot. Use `Chat::Header`'s `right` slot for actions inside that header, next to its title. `right_header_mobile` is the compact set below the chat `sm` breakpoint (640px, the same cutoff as `Chat::Layout`'s default `split_breakpoint`). Below `sm` the mobile part is shown and `right_header` is hidden when both are passed. At `sm` and up, `right_header` is shown and the mobile part is hidden. Pass only `right_header` and it stays visible at every width. Pass only `right_header_mobile` and it shows below `sm`; with no `header` the bar hides at `sm` and up (`sm:hidden`). Both parts render into the DOM and CSS hides one, so do not repeat ids or Stimulus targets across the two slots. Pair `right_header` with `right_header_mobile` when the desktop set has four or more actions, or a long-text badge. The swap follows the viewport (`sm` = 640px), not the panel's container width. A narrow panel on a wide viewport, including a `Chat::Layout` split column, still shows the desktop set.
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

Actions that should stay on the right of a long title use `right_header`. The panel does not pad that bar. The right part is `w-min`, so that content must not wrap.

```erb
<%= render FlatPack::Chat::Panel::Component.new do |panel| %>
  <% panel.header do %>
    <div class="flex min-w-0 items-center p-4">
      <p class="min-w-0 truncate text-sm font-semibold">Riverside studio quarterly launch planning with Alicia, Mina, and the full design chat group</p>
    </div>
  <% end %>

  <% panel.right_header do %>
    <div class="flex items-center gap-2 whitespace-nowrap p-4">
      <%= render FlatPack::Button::Component.new(icon: "search", icon_only: true, style: :ghost, size: :sm, title: "Search", aria: { label: "Search conversation" }) %>
      <%= render FlatPack::Button::Component.new(icon: "bookmark", icon_only: true, style: :ghost, size: :sm, title: "Save", aria: { label: "Save conversation" }) %>
      <%= render FlatPack::Button::Component.new(icon: "bell", icon_only: true, style: :ghost, size: :sm, title: "Mute", aria: { label: "Mute conversation" }) %>
      <%= render FlatPack::Button::Component.new(icon: "dots", icon_only: true, style: :ghost, size: :sm, title: "More", aria: { label: "More conversation actions" }) %>
      <%= render FlatPack::Badge::Component.new(text: "4 new", style: :primary, size: :sm) %>
    </div>
  <% end %>

  <% panel.right_header_mobile do %>
    <div class="flex items-center gap-2 whitespace-nowrap p-4">
      <%= render FlatPack::Button::Component.new(icon: "dots", icon_only: true, style: :ghost, size: :sm, title: "More", aria: { label: "More conversation actions on a small screen" }) %>
    </div>
  <% end %>
<% end %>
```

Four or more actions, or a long-text badge, belong in that pair. The swap follows the viewport, not the panel width, so a narrow split column on a wide screen still shows `right_header`. Give the two slots different controls; both stay in the DOM.

## Accessibility
- Message list jump button includes explicit `aria-label`. Its shadow is `--chat-jump-button-shadow` (the Tailwind `shadow-lg` utility, not `--shadow-lg`). Keyboard focus uses the browser outline in `--focus-outline-color` (`#101010` on light themes, `--surface-content-color` on dark), mapped through `--button-focus-ring-color` on `.fp-chat-jump`.
- Date dividers render `role="separator"` with labels.
- Outgoing/incoming reveal-actions surfaces are keyboard focusable (`role="button"`, `tabindex="0"`).
- Reveal trays fade with `transition-opacity duration-[var(--duration-fast)]` so `prefers-reduced-motion` token collapse applies. Do not use Tailwind `duration-150` on those trays.
- Send button sets contextual `aria-label` (`"Send message"` / `"Sending..."`).
- `right_header` and `right_header_mobile` do not name their controls. Icon buttons there need `title` and `aria-label`. Do not reuse the same `id` or Stimulus target on both slots; both are in the DOM.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Stimulus controllers: `flat-pack--chat-scroll`, `flat-pack--chat-grouping`, `flat-pack--chat-textarea`, `flat-pack--chat-message-actions`, `flat-pack--chat-image-deck`.
- Message history loading uses `FlatPack::PaginationInfinite::Component` when configured.

---

## Architecture Reference

### Stimulus Controllers

#### `chat_scroll_controller.js`

- **Location**: `app/javascript/flat_pack/controllers/chat_scroll_controller.js`
- **Targets**: `messages`, `jumpButtonContainer`
- **Values**: `stickToBottom`
- **Actions**: `checkScroll()`, `jump()`, `newMessageAdded()`
- **Features**: Auto-scrolls to bottom, shows/hides jump button, smooth scrolling

#### `chat_layout_controller.js`

- **Location**: `app/javascript/flat_pack/controllers/chat_layout_controller.js`
- **Targets**: `sidebar`, `panel`
- **Values**: `breakpoint` (Number, default `640`) — set by `Chat::Layout` from `split_breakpoint`
- **Actions**: `openPanel()`, `showPanel()`, `showSidebar()`
- **Features**: Below the breakpoint a `:split` layout shows one column at a time; picking a conversation opens the panel and scrolls it to the latest message, and Back returns to the list. At and above the breakpoint both columns stay visible.

### Design Patterns

#### BaseComponent Inheritance

All components inherit from `FlatPack::BaseComponent`:

- Use `system_arguments` for HTML attributes
- Use `merge_attributes` for attribute merging
- Use `classes()` method with TailwindMerge

#### Constant-Based Styling

Tailwind classes are defined as frozen constants with inline comments for Tailwind CSS scanning. Explicit class literals ensure proper CSS generation.

#### Validation

Required props are validated; enums are validated with descriptive `ArgumentError` messages.

### Key Behaviours

- **Message bubbles** — Incoming uses `--chat-message-incoming-background-color` (`--surface-muted-background-color`) and `--surface-content-color`. Outgoing uses `--chat-message-outgoing-background-color` (`--surface-hover-background-color` on the default palette, `#f0f0f0`) and the same foreground. Dark and ocean set their own outgoing fill so the bubbles stay apart. Timestamps and read receipts use `--surface-muted-content-color` under the bubble. Attachment icons use the attachment tokens on the attachment card. Links inside a bubble inherit the bubble text colour.
- **Message states** — Opacity changes for `:sending`, error indicators for `:failed`, read receipts for `:read`.
- **Auto-growing textarea** — Expands as the user types up to a max height with smooth transitions.
- **Smart scrolling** — Auto-scrolls to bottom; shows a jump button when scrolled up. The message list hides its bar with `--pane-scrollbar-width`. It is a region named "Messages" and sits in the tab order, so a list with no links still scrolls from the keyboard. The fade uses `--pane-scroll-fade-size`.
- **Avatar integration** — Seamless use of `FlatPack::Avatar::Component` and `FlatPack::AvatarGroup::Component`.
- **Attachments** — File attachments with icons, image attachments with thumbnails, download/view links.
- **Inbox rows** — Name, preview, time, and unread count. Unread uses the primary badge. The row does not clip the count against its corner radius.

### Integration Points

| Integration | Notes |
|-------------|-------|
| Avatar | Used in message groups |
| AvatarGroup | Used in chat headers |
| BaseComponent | All components inherit from it |
| CSS variables | Bubble fills are `--chat-message-incoming-*` and `--chat-message-outgoing-*`. Outgoing follows the hover surface and foreground text. Also uses `--transition-*` (aliases of `--duration-*`) and `--radius-*`; named themes inherit via `data-theme` |

### Source Files

**Components**
- `app/components/flat_pack/chat/layout/component.rb`
- `app/components/flat_pack/chat/panel/component.rb`
- `app/components/flat_pack/chat/message_list/component.rb`
- `app/components/flat_pack/chat/date_divider/component.rb`
- `app/components/flat_pack/chat/message_group/component.rb`
- `app/components/flat_pack/chat/message/component.rb`
- `app/components/flat_pack/chat/message_meta/component.rb`
- `app/components/flat_pack/chat/composer/component.rb`
- `app/components/flat_pack/chat/typing_indicator/component.rb`
- `app/components/flat_pack/chat/attachment/component.rb`

**Tests**
- `test/components/flat_pack/chat/message_component_test.rb`
- `test/components/flat_pack/chat/message_group_component_test.rb`
- `test/components/flat_pack/chat/composer_component_test.rb`
- `test/components/flat_pack/chat/message_list_component_test.rb`
