# FlatPack Components Index (Agent-First)

This is the canonical component index for AI and human lookup.

- Canonical format: `docs/components/DOC_FORMAT.md`
- Machine-readable inventory: `docs/components/manifest.yml`

## How to use this index

1. Find the UI task in the table below.
2. Open the linked component page for props, variants, and examples.
3. Use the canonical class name listed here.

## Component Catalog

| Component | Purpose | Primary Class | Docs |
|---|---|---|---|
| Accordion | Expand/collapse sections of content | `FlatPack::Accordion::Component` | [accordion.md](accordion.md) |
| Alert | Inline feedback and status messaging | `FlatPack::Alert::Component` | [alert.md](alert.md) |
| Avatar | User/profile visual identity | `FlatPack::Avatar::Component` | [avatar.md](avatar.md) |
| Avatar Group | Compact group of avatars | `FlatPack::AvatarGroup::Component` | [avatar-group.md](avatar-group.md) |
| Badge | Small status/count labels | `FlatPack::Badge::Component` | [badge.md](badge.md) |
| Breadcrumb | Hierarchical navigation trail | `FlatPack::Breadcrumb::Component` | [breadcrumb.md](breadcrumb.md) |
| Button | Trigger actions and links | `FlatPack::Button::Component` | [button.md](button.md) |
| Button Dropdown | Button-triggered action menu | `FlatPack::Button::Dropdown::Component` | [button-dropdown.md](button-dropdown.md) |
| Card | Structured content container | `FlatPack::Card::Component` | [card.md](card.md) |
| Chart | Data visualization cards/charts | `FlatPack::Chart::Component` | [charts.md](charts.md) |
| Chat | Messaging UI primitives | `FlatPack::Chat::Panel::Component` | [chat.md](chat.md) |
| Chip + Chip Group | Compact tags/tokens with optional actions | `FlatPack::Chip::Component` | [chips.md](chips.md) |
| Collapse | Progressive disclosure region | `FlatPack::Collapse::Component` | [collapse.md](collapse.md) |
| Comments Inline Input | Minimal single-line comment input + inline submit | `FlatPack::Comments::InlineInput::Component` | [comments-inline-input.md](comments-inline-input.md) |
| Comments Composer | Comment input/composer | `FlatPack::Comments::Composer::Component` | [comments-composer.md](comments-composer.md) |
| Comments Item | Single comment item | `FlatPack::Comments::Item::Component` | [comments-item.md](comments-item.md) |
| Comments Replies | Nested/reply comment region | `FlatPack::Comments::Replies::Component` | [comments-replies.md](comments-replies.md) |
| Comments Thread | Full threaded comments view | `FlatPack::Comments::Thread::Component` | [comments-thread.md](comments-thread.md) |
| Input Components | Form inputs (text, select, checkbox, etc.) | `FlatPack::TextInput::Component` | [inputs.md](inputs.md) |
| List | Styled list container/items | `FlatPack::List::Component` | [list.md](list.md) |
| Grid | Responsive grid layout container | `FlatPack::Grid::Component` | [grid.md](grid.md) |
| Navbar | App-level nav shell | `FlatPack::Navbar::Component` | [navbar.md](navbar.md) |
| Pagination Infinite | Incremental loading pagination | `FlatPack::PaginationInfinite::Component` | [pagination-infinite.md](pagination-infinite.md) |
| Picker | Reusable image/file selector with consumer-defined behavior | `FlatPack::Picker::Component` | [picker.md](picker.md) |
| Progress | Progress indicators/bars | `FlatPack::Progress::Component` | [progress.md](progress.md) |
| Range Input | Slider/range selection | `FlatPack::RangeInput::Component` | [range-input.md](range-input.md) |
| Search | Reusable search UI | `FlatPack::Search::Component` | [search.md](search.md) |
| Sidebar | Sidebar navigation primitives | `FlatPack::Sidebar::Component` | [sidebar.md](sidebar.md) |
| Sidebar Group | Collapsible sidebar groups | `FlatPack::Sidebar::Group::Component` | [sidebar_group.md](sidebar_group.md) |
| Sidebar Layout | Sidebar + content page layout | `FlatPack::SidebarLayout::Component` | [sidebar_layout.md](sidebar_layout.md) |
| Skeleton | Loading placeholders | `FlatPack::Skeleton::Component` | [skeleton.md](skeleton.md) |
| Sortable Tables | Sortable table behavior/API | `FlatPack::Table::Component` | [sortable-tables.md](sortable-tables.md) |
| Sortable Tables Examples | Sortable usage examples | `FlatPack::Table::Component` | [sortable-tables-examples.md](sortable-tables-examples.md) |
| Table | Structured data tables | `FlatPack::Table::Component` | [table.md](table.md) |
| Timeline | Chronological sequence UI | `FlatPack::Timeline::Component` | [timeline.md](timeline.md) |
| Top Nav | Top navigation bar | `FlatPack::TopNav::Component` | [top_nav.md](top_nav.md) |

## Coverage Notes

- Some source component directories are composition/internal helpers and may not have dedicated docs pages.
- See `undocumented_or_internal_candidates` in `docs/components/manifest.yml` for current gaps.
