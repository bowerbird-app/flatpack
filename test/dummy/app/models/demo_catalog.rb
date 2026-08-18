# frozen_string_literal: true

# Single source of truth for dummy-app demo navigation and top-nav search.
# Sidebar and searchable_items both read from here so they stay aligned.
class DemoCatalog
  # Each section has a title and entries.
  # Entry shapes:
  #   item:  { type: :item, title:, path:, description:, icon: }
  #   group: { type: :group, title:, icon:, children: [item hashes without type] }
  SECTIONS = [
    {
      title: "Getting Started",
      entries: [
        {type: :item, title: "Overview", path: "/demo", description: "FlatPack component library home", icon: :home},
        {
          type: :group,
          title: "Themes",
          icon: :cog,
          children: [
            {title: "Theme Variables", path: "/themes", description: "Theme token values and CSS variable reference", icon: :type},
            {title: "System theme", path: "/themes/demos/system", description: "System color scheme demo", icon: :monitor},
            {title: "Light theme", path: "/themes/demos/light", description: "Light color scheme demo", icon: :monitor},
            {title: "Dark theme", path: "/themes/demos/dark", description: "Dark color scheme demo", icon: :monitor},
            {title: "Ocean theme", path: "/themes/demos/ocean", description: "Ocean color scheme demo", icon: :monitor},
            {title: "Rounded theme", path: "/themes/demos/rounded", description: "Rounded theme demo", icon: :monitor}
          ]
        }
      ]
    },
    {
      title: "Interactive",
      entries: [
        {
          type: :group,
          title: "Buttons",
          icon: :square,
          children: [
            {title: "Buttons", path: "/demo/buttons", description: "Button styles, sizes, and states", icon: :square},
            {title: "Links", path: "/demo/links", description: "Link component examples", icon: :link},
            {title: "Pill Buttons", path: "/demo/buttons/pills", description: "Pill-style button and filter links", icon: :square},
            {title: "Segmented", path: "/demo/buttons/segmented", description: "Segmented button selected-state patterns", icon: :square},
            {title: "Button Groups", path: "/demo/buttons/groups", description: "Grouped buttons wrapped together", icon: :square},
            {title: "Dropdowns", path: "/demo/buttons/dropdowns", description: "Button dropdown menus and positions", icon: :chevron_down}
          ]
        },
        {type: :item, title: "Modals", path: "/demo/modals", description: "Dialog overlays with focus trap", icon: :box},
        {type: :item, title: "Popovers", path: "/demo/popovers", description: "Click-triggered floating content", icon: :question},
        {type: :item, title: "Tooltips", path: "/demo/tooltips", description: "Hover/focus tooltips", icon: :question},
        {
          type: :group,
          title: "Tabs",
          icon: :folder,
          children: [
            {title: "Underline Tabs", path: "/demo/tabs", description: "Underlined tabs with keyboard navigation", icon: :folder},
            {title: "Pills tabs", path: "/demo/tabs/pills", description: "Pill-style tabs with shared accessibility behavior", icon: :folder},
            {title: "Stacked pills", path: "/demo/tabs/stacked_pills", description: "Vertical pill-style tabs with two-column layout on larger screens", icon: :folder}
          ]
        },
        {type: :item, title: "Toasts", path: "/demo/toasts", description: "Auto-dismissing notifications", icon: :bell},
        {type: :item, title: "Collapse", path: "/demo/collapse", description: "Expandable and collapsible content sections", icon: :chevron_down},
        {type: :item, title: "Accordion", path: "/demo/accordion", description: "Accordion with single or multiple open panels", icon: :chevron_down}
      ]
    },
    {
      title: "Forms",
      entries: [
        {
          type: :group,
          title: "Forms",
          icon: :edit_3,
          children: [
            {title: "Submit Buttons", search_title: "Forms", path: "/demo/forms", description: "Form submit patterns with HTTP methods", icon: :square},
            {title: "Text Input", path: "/demo/forms/text_input", description: "Single-line text input examples", icon: :type},
            {title: "Password Input", path: "/demo/forms/password_input", description: "Masked text input with visibility toggle", icon: :settings},
            {title: "Email Input", path: "/demo/forms/email_input", description: "Email-specific input examples", icon: :type},
            {title: "Phone Input", path: "/demo/forms/phone_input", description: "Telephone input examples", icon: :type},
            {title: "Search Input", path: "/demo/forms/search_input", description: "Search field with helper affordances", icon: :search},
            {title: "URL Input", path: "/demo/forms/url_input", description: "URL input examples", icon: :type},
            {title: "Text Area", path: "/demo/forms/text_area", description: "Multiline text input examples", icon: :align_left},
            {title: "Number Input", path: "/demo/forms/number_input", description: "Numeric input with constraints", icon: :type},
            {title: "Date Input", path: "/demo/forms/date_input", description: "Date picker input examples", icon: :calendar},
            {title: "Date Range Input", path: "/demo/forms/date_range_input", description: "Date range input examples", icon: :calendar},
            {title: "Date Time Input", path: "/demo/forms/date_time_input", description: "Datetime-local input examples", icon: :calendar},
            {title: "Time Input", path: "/demo/forms/time_input", description: "Native time input examples", icon: :calendar},
            {title: "File Input", path: "/demo/forms/file_input", description: "File upload input examples", icon: :box},
            {title: "Checkbox", path: "/demo/forms/checkbox", description: "Checkbox input examples", icon: :square},
            {title: "Radio Group", path: "/demo/forms/radio_group", description: "Single-choice radio group examples", icon: :square},
            {title: "Select", path: "/demo/forms/select", description: "Dropdown select input examples", icon: :chevron_down},
            {title: "Nested Multiselect", path: "/demo/forms/nested_multiselect", description: "Parent and child checkbox multiselect examples", icon: :square},
            {title: "Picker", path: "/demo/picker", description: "Reusable file and image picker for any workflow", icon: :image},
            {title: "Switch", path: "/demo/forms/switch", description: "Toggle switch input examples", icon: :settings},
            {title: "Range Input", path: "/demo/range_input", description: "Slider input with live value", icon: :settings},
            {title: "Combined Form", path: "/demo/forms/combined", description: "Full form with multiple input types", icon: :edit_3}
          ]
        }
      ]
    },
    {
      title: "Email",
      entries: [
        {
          type: :group,
          title: "Email Components",
          icon: :envelope,
          children: [
            {title: "Button", search_title: "Email Button", path: "/demo/email/button", description: "Email-safe CTA button component", icon: :square},
            {title: "Card", search_title: "Email Card", path: "/demo/email/card", description: "Email-safe table-based content wrapper", icon: :box},
            {title: "Footer Links", search_title: "Email Footer Links", path: "/demo/email/footer_links", description: "Email-safe footer links list component", icon: :link},
            {title: "Template Example", search_title: "Email Template Example", path: "/demo/email/template_example", description: "Composed transactional email example built from FlatPack email components", icon: :envelope}
          ]
        }
      ]
    },
    {
      title: "Data Display",
      entries: [
        {type: :item, title: "Modal Filter", path: "/demo/modal_filter", description: "Modal-only filter content with dedicated Filter trigger flow", icon: :funnel},
        {
          type: :group,
          title: "Tables",
          icon: :table,
          children: [
            {title: "Basic", search_title: "Tables: Basic", path: "/demo/tables/basic", description: "Basic table examples with formatting and actions", icon: :table},
            {title: "Empty", search_title: "Tables: Empty", path: "/demo/tables/empty", description: "Empty state table rendering with no rows", icon: :inbox},
            {title: "Sortable", search_title: "Tables: Sortable", path: "/demo/tables/sortable", description: "Sortable columns with Turbo frame updates", icon: :chevron_down},
            {title: "Draggable", search_title: "Tables: Draggable", path: "/demo/tables/draggable", description: "Drag-and-drop row reordering with persistence", icon: :dashboard}
          ]
        },
        {type: :item, title: "Pagination", path: "/demo/pagination", description: "Page navigation with Pagy", icon: :chevron_right},
        {type: :item, title: "Infinite Scroll", path: "/demo/pagination_infinite", description: "Infinite scrolling pagination patterns", icon: :chevron_down},
        {
          type: :group,
          title: "Charts",
          icon: :dashboard,
          children: [
            {title: "Overview", search_title: "Charts", path: "/demo/charts", description: "Data visualization with ApexCharts", icon: :dashboard},
            {title: "Types", search_title: "Charts: Types", path: "/demo/charts/types", description: "Line, column, bar, area, donut, gauge, and geo charts", icon: :dashboard},
            {title: "Composition", search_title: "Charts: Composition", path: "/demo/charts/composition", description: "Slots, filters, grids, and card-free chart layouts", icon: :dashboard},
            {title: "Setup", search_title: "Charts: Setup", path: "/demo/charts/setup", description: "Setup instructions and ApexCharts options", icon: :dashboard},
            {title: "Default Filter", search_title: "Charts: Default Filter", path: "/demo/charts/default_filter", description: "Date range and optional status filter for chart controls", icon: :dashboard}
          ]
        },
        {
          type: :group,
          title: "Grid",
          icon: :dashboard,
          children: [
            {title: "Layouts", search_title: "Grid", path: "/demo/grid", description: "Responsive grid layouts", icon: :dashboard},
            {title: "Two Columns", search_title: "Grid: Two Columns", path: "/demo/grid/two_columns", description: "Two-column layout with one card in each column", icon: :dashboard},
            {title: "Movable Cards", search_title: "Grid: Movable Cards", path: "/demo/grid/movable_cards", description: "Draggable card grid with persisted ordering", icon: :chevron_down}
          ]
        },
        {type: :item, title: "Code Blocks", path: "/demo/code_blocks", description: "Reusable snippets for demo pages", icon: :type},
        {type: :item, title: "Avatars", path: "/demo/avatars", description: "Avatar examples with images, initials, and status", icon: :user},
        {type: :item, title: "Avatar Groups", path: "/demo/avatar_groups", description: "Stacked avatar groups with overflow and overlap", icon: :users},
        {type: :item, title: "Carousel", path: "/demo/carousel?anchor=component-method-variables-carousel-0", description: "FlatPack carousel demo with mixed media and navigation controls", icon: :image},
        {type: :item, title: "Progress", path: "/demo/progress", description: "Progress indicators and loading states", icon: :dashboard},
        {type: :item, title: "Skeletons", path: "/demo/skeletons", description: "Skeleton loading placeholders", icon: :square},
        {type: :item, title: "List", path: "/demo/list", description: "List component demos and selectable rows", icon: :align_left},
        {type: :item, title: "Tree", path: "/demo/tree", description: "Folder tree views for folder structures and hierarchical lists", icon: :folder},
        {type: :item, title: "Timeline", path: "/demo/timeline", description: "Chronological timeline layouts", icon: :calendar},
        {type: :item, title: "Timestamp", path: "/demo/timestamp", description: "Relative timestamps with hover tooltip absolute time", icon: :calendar},
        {type: :item, title: "Notification", path: "/demo/notification", description: "Notification popover and list patterns", icon: :bell}
      ]
    },
    {
      title: "Helpers",
      entries: [
        {type: :item, title: "Local Time", path: "/demo/local_time", description: "Local time helper formatting", icon: :clock},
        {type: :item, title: "Red Dot", path: "/demo/red_dot", description: "Unread and attention indicator dots", icon: :bell}
      ]
    },
    {
      title: "Layout",
      entries: [
        {type: :item, title: "Hero", path: "/pages/hero", description: "Landing-page hero sections with layout variants", icon: :rectangle_group},
        {
          type: :group,
          title: "Cards",
          icon: :box,
          children: [
            {title: "Overview", search_title: "Cards", path: "/demo/cards", description: "Composed card layouts", icon: :box},
            {title: "Styles", search_title: "Cards: Styles", path: "/demo/cards/styles", description: "Card styles, padding, slots, and clickable cards", icon: :box},
            {title: "Media", search_title: "Cards: Media", path: "/demo/cards/media", description: "Media gallery cards and aspect ratios", icon: :image},
            {title: "Composed", search_title: "Cards: Composed", path: "/demo/cards/composed", description: "Product, stat, profile, pricing, and list cards", icon: :box}
          ]
        },
        {
          type: :group,
          title: "Text",
          icon: :align_left,
          children: [
            {title: "Page Title", path: "/demo/page_header", description: "Page title with optional subtitle", icon: :type},
            {title: "Content", path: "/demo/text/content", description: "Body content text patterns", icon: :align_left},
            {title: "Quote", path: "/demo/text/quote", description: "Blockquote and citation text examples", icon: :message_circle}
          ]
        },
        {type: :item, title: "Empty State", path: "/demo/empty_state", description: "User-friendly empty states", icon: :folder}
      ]
    },
    {
      title: "Feedback",
      entries: [
        {type: :item, title: "Alerts", path: "/demo/alerts", description: "Status and feedback messages", icon: :alert},
        {type: :item, title: "Badges", path: "/demo/badges", description: "Label and status indicators", icon: :dashboard},
        {type: :item, title: "Chips", path: "/demo/chips", description: "Compact filter and tag components", icon: :dashboard},
        {type: :item, title: "Chip Groups", path: "/demo/chip_groups", description: "Wrapping and non-wrapping chip collections", icon: :dashboard}
      ]
    },
    {
      title: "Navigation",
      entries: [
        {type: :item, title: "Breadcrumbs", path: "/demo/breadcrumbs", description: "Hierarchical navigation trails", icon: :chevron_right},
        {type: :item, title: "Page Nav", path: "/demo/page_nav", description: "Back, close, and page action navigation bar", icon: :chevron_left},
        {type: :item, title: "Top Nav", path: "/demo/navbar", description: "Header layout with left, center, and right slots", icon: :monitor},
        {type: :item, title: "Search", path: "/demo/search", description: "Reusable search component with live results", icon: :search},
        {
          type: :group,
          title: "Sidebar",
          icon: :laptop,
          children: [
            {title: "Layout", search_title: "Sidebar Layout", path: "/demo/sidebar_layout", description: "Sidebar layout shell with left/right positioning", icon: :monitor},
            {title: "Basic", search_title: "Sidebar Basic", path: "/demo/sidebar/basic", description: "Basic sidebar with header, items, and footer", icon: :home},
            {title: "Header", search_title: "Sidebar Header", path: "/demo/sidebar/header", description: "Header configurations for sidebar branding and actions", icon: :type},
            {title: "Footer", search_title: "Sidebar Footer", path: "/demo/sidebar/footer", description: "Footer patterns for status, metadata, and account actions", icon: :align_left},
            {title: "Badges", search_title: "Sidebar with Badges", path: "/demo/sidebar/badges", description: "Sidebar navigation items with badges", icon: :dashboard},
            {title: "Grouped", search_title: "Sidebar Grouped", path: "/demo/sidebar/grouped", description: "Sidebar navigation with grouped items", icon: :folder},
            {title: "Collapsible", search_title: "Sidebar Collapsible", path: "/demo/sidebar/collapsible", description: "Sidebar groups that expand and collapse", icon: :chevron_down},
            {title: "Collapsed", search_title: "Sidebar Collapsed", path: "/demo/sidebar/collapsed", description: "Icon-only collapsed sidebar pattern", icon: :menu},
            {title: "Complete", search_title: "Sidebar Complete", path: "/demo/sidebar/complete", description: "Full-featured sidebar composition", icon: :box},
            {title: "Section Title", search_title: "Sidebar Section Title", path: "/demo/sidebar/section_title", description: "Category labels that group sidebar navigation items", icon: :type}
          ]
        },
        {type: :item, title: "Bottom Nav", path: "/mobile/bottom_nav", description: "Mobile bottom navigation demo", icon: :menu},
        {type: :item, title: "Mobile", path: "/mobile", description: "Mobile demo index", icon: :menu, search_only: true}
      ]
    },
    {
      title: "Demo",
      entries: [
        {type: :item, title: "Admin Page", path: "/demo/admin", description: "Admin page composition demo", icon: :monitor},
        {type: :item, title: "Comments", path: "/demo/comments", description: "Comments threads and reply composer patterns", icon: :users},
        {
          type: :group,
          title: "Chat",
          icon: :message_circle,
          children: [
            {title: "Chat Demo", path: "/demo/chat/demo", description: "End-to-end chat demo experience", icon: :message_circle},
            {title: "Layout", search_title: "Chat Layout", path: "/demo/chat/layout", description: "Two-panel chat layout examples", icon: :dashboard},
            {title: "Panel", search_title: "Chat Panel", path: "/demo/chat/panel", description: "Chat panel container patterns", icon: :box},
            {title: "Message List", search_title: "Chat Message List", path: "/demo/chat/message_list", description: "Chat message list patterns", icon: :align_left},
            {title: "Message Group", search_title: "Chat Message Group", path: "/demo/chat/message_group", description: "Grouped chat message patterns", icon: :users},
            {title: "Sent Message", search_title: "Chat Sent Message", path: "/demo/chat/sent_message", description: "Outgoing message examples", icon: :message_circle},
            {title: "Received Message", search_title: "Chat Received Message", path: "/demo/chat/received_message", description: "Incoming message examples", icon: :message_circle},
            {title: "File Message", search_title: "Chat File Message", path: "/demo/chat/file_message", description: "File attachment message examples", icon: :file},
            {title: "Images", search_title: "Chat Images", path: "/demo/chat/images", description: "Single and multi-image chat message examples with carousel lightbox", icon: :image},
            {title: "System Message", search_title: "Chat System Message", path: "/demo/chat/system_message", description: "System message examples", icon: :info},
            {title: "Inbox Row", search_title: "Chat Inbox Row", path: "/demo/chat/inbox_row", description: "Inbox row component examples", icon: :align_left},
            {title: "Attachment", search_title: "Chat Attachment", path: "/demo/chat/attachment", description: "Attachment component examples", icon: :file},
            {title: "Date Divider", search_title: "Chat Date Divider", path: "/demo/chat/date_divider", description: "Date divider component examples", icon: :calendar},
            {title: "Typing Indicator", search_title: "Chat Typing Indicator", path: "/demo/chat/typing_indicator", description: "Typing indicator component examples", icon: :edit_3},
            {title: "Composer", search_title: "Chat Composer", path: "/demo/chat/composer", description: "Composer input and action patterns", icon: :edit_3}
          ]
        },
        {type: :item, title: "Articles", path: "/demo/articles", description: "Articles CRUD demo with rich text", icon: :edit_3}
      ]
    }
  ].freeze

  def self.sections
    SECTIONS
  end

  def self.searchable_items
    items = []

    SECTIONS.each do |section|
      section.fetch(:entries).each do |entry|
        case entry[:type]
        when :item
          next if entry[:sidebar_only]

          items << search_entry(entry)
        when :group
          entry.fetch(:children).each do |child|
            next if child[:sidebar_only]

            items << search_entry(child)
          end
        end
      end
    end

    # Keep a friendly Tables alias that matches prior search behavior.
    basic = items.find { |item| item[:title] == "Tables: Basic" }
    items.unshift({title: "Tables", description: basic[:description], url: basic[:url]}) if basic

    items.compact
  end

  def self.search_entry(entry)
    {
      title: entry[:search_title] || entry.fetch(:title),
      description: entry.fetch(:description),
      url: resolve_path(entry.fetch(:path))
    }
  end
  private_class_method :search_entry

  def self.resolve_path(path)
    path
  end
  private_class_method :resolve_path
end
