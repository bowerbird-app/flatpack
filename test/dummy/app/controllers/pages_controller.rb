# frozen_string_literal: true

require "ostruct"
require "pagy"
require "pagy/extras/array"

class PagesController < ApplicationController
  include Pagy::Backend

  before_action :load_table_demo_data, only: %i[tables_basic tables_sortable tables_draggable]

  def demo
    @component_index = cached_component_index
  end

  def buttons
  end

  def tables_basic
  end

  def tables_empty
  end

  def tables_sortable
  end

  def tables_draggable
  end

  def tables_reorder
    unless demo_table_rows_table_exists?
      render json: {
        ok: false,
        error: "demo_table_rows table is missing. Run `bin/rails db:migrate` in test/dummy.",
        version: "0"
      }, status: :service_unavailable
      return
    end

    payload = reorder_payload
    scope = payload[:scope].presence || {list_key: DemoTableRow::DEFAULT_LIST_KEY}

    rows = DemoTableRow.where(scope)

    result = Ordering::ReorderService.call(
      relation: rows,
      items: payload[:items],
      strategy: payload[:strategy],
      version: payload[:version]
    )

    if result[:ok]
      render json: {
        ok: true,
        resource: payload[:resource],
        strategy: result[:strategy],
        scope: scope,
        version: result[:version],
        items: result[:items]
      }
    else
      render json: {
        ok: false,
        error: result[:error],
        version: demo_table_version(scope)
      }, status: result[:status]
    end
  rescue Ordering::ReorderService::InvalidPayload => e
    render json: {ok: false, error: e.message}, status: :unprocessable_entity
  end

  def inputs
  end

  def badges
  end

  def chips
  end

  def alerts
  end

  def forms
    # Display forms page
  end

  def forms_text_input
  end

  def forms_password_input
  end

  def forms_email_input
  end

  def forms_phone_input
  end

  def forms_search_input
  end

  def forms_url_input
  end

  def forms_text_area
  end

  def forms_number_input
  end

  def forms_date_input
  end

  def forms_file_input
  end

  def forms_checkbox
  end

  def forms_radio_group
  end

  def forms_select
  end

  def forms_switch
  end

  def forms_combined
  end

  def forms_create
    # Handle POST form submission
    flash[:notice] = "Form submitted successfully with POST method"
    redirect_to demo_forms_path
  end

  def forms_update
    # Handle PATCH/PUT form submission
    flash[:notice] = "Form submitted successfully with #{request.method} method"
    redirect_to demo_forms_path
  end

  def forms_destroy
    # Handle DELETE form submission
    flash[:notice] = "Form submitted successfully with DELETE method"
    redirect_to demo_forms_path
  end

  def navbar
  end

  def search
  end

  def search_results
    query = params[:q].to_s.strip.downcase

    if query.blank?
      render json: {results: []}
      return
    end

    results = searchable_items.select do |item|
      item[:title].downcase.include?(query) || item[:description].downcase.include?(query)
    end

    render json: {results: results.first(10)}
  end

  def sidebar_layout
  end

  def sidebar_basic
  end

  def sidebar_header
  end

  def sidebar_footer
  end

  def sidebar_badges
  end

  def sidebar_grouped
  end

  def sidebar_collapsible
  end

  def sidebar_collapsed
  end

  def sidebar_complete
  end

  def cards
  end

  def breadcrumbs
  end

  def modals
  end

  def popovers
  end

  def tooltips
  end

  def tabs
  end

  def tabs_pills
  end

  def tabs_stacked_pills
  end

  def toasts
  end

  def page_header
  end

  def text_quote
  end

  def empty_state
  end

  def grid
    @products = Array.new(12) do |i|
      OpenStruct.new(
        id: i + 1,
        name: "Product #{i + 1}",
        price: rand(10..100),
        description: "Description for product #{i + 1}"
      )
    end
  end

  def grid_two_columns
  end

  def grid_movable_cards
    ensure_demo_movable_cards!

    @movable_cards = demo_table_rows_table_exists? ? DemoTableRow.where(list_key: movable_cards_list_key).ordered : []
    @movable_cards_version = demo_table_rows_table_exists? ? demo_table_version(list_key: movable_cards_list_key) : "0"
  end

  def pagination
    records = Array.new(100) do |i|
      OpenStruct.new(
        id: i + 1,
        name: "User #{i + 1}",
        email: "user#{i + 1}@example.com",
        status: %w[active inactive pending].sample,
        category: %w[Technology Business Marketing Design].sample,
        views_count: rand(100..5_000),
        published_at: rand(60).days.ago
      )
    end

    @pagy, @records = pagy_array(records, items: 10)
  rescue NameError
    # Pagy not initialized, create mock
    @pagy = OpenStruct.new(
      page: 1,
      pages: 10,
      count: 100,
      items: 10,
      from: 1,
      to: 10,
      prev: nil,
      next: 2,
      series: ["1", 2, 3, 4, 5, :gap, 10]
    )
    @records = Array.new(10) { |i| OpenStruct.new(id: i + 1, name: "Item #{i + 1}") }
  end

  def charts
    @sales_data = [
      {name: "Jan", value: 30},
      {name: "Feb", value: 40},
      {name: "Mar", value: 45},
      {name: "Apr", value: 50},
      {name: "May", value: 49},
      {name: "Jun", value: 60}
    ]
  end

  def code_blocks
  end

  def avatars
  end

  def comments
  end

  def chat_demo
    if chat_tables_available?
      ensure_chat_demo_messages!
      @chat_group = ChatGroup.order(:id).first
      @chat_messages = recent_chat_messages(@chat_group)
    else
      @chat_group = nil
      @chat_messages = []
    end
  end

  def chat_layout
  end

  def chat_panel
  end

  def chat_message_list
  end

  def chat_message_group
  end

  def chat_message
  end

  def chat_message_meta
  end

  def chat_attachment
  end

  def chat_date_divider
  end

  def chat_typing_indicator
  end

  def chat_composer
  end

  def chat_textarea
  end

  def chat_send_button
  end

  def progress
  end

  def collapse
  end

  def pagination_infinite
    @pagy, @records = paginated_infinite_records
    @has_more = @pagy.next.present?
    @infinite_url = @has_more ? demo_pagination_infinite_path(page: @pagy.next) : "#"

    cards_infinite_url = @has_more ? demo_pagination_infinite_path(page: @pagy.next, view: :cards) : "#"

    return unless request.xhr?

    cards_view = params[:view].to_s == "cards"
    render partial: cards_view ? "pages/pagination_infinite_cards_results" : "pages/pagination_infinite_results",
      locals: {
        records: @records,
        pagy: @pagy,
        has_more: @has_more,
        infinite_url: cards_view ? cards_infinite_url : @infinite_url
      }
  end

  def range_input
  end

  def skeletons
  end

  def list
  end

  def timeline
  end

  private

  def cached_component_index
    Rails.cache.fetch(component_index_cache_key, expires_in: 10.minutes) do
      build_component_index
    end
  end

  def component_index_cache_key
    ["dummy/component_index", component_index_cache_version]
  end

  def component_index_cache_version
    component_files = Dir.glob(FlatPack::Engine.root.join("app/components/flat_pack/**/*.rb"))
    doc_files = Dir.glob(FlatPack::Engine.root.join("docs/components/*.md"))
    all_files = component_files + doc_files

    latest_mtime = all_files.filter_map do |path|
      File.mtime(path).to_i if File.exist?(path)
    end.max || 0

    "#{latest_mtime}-#{all_files.size}"
  end

  def build_component_index
    component_root = FlatPack::Engine.root.join("app/components/flat_pack")
    files = (
      Dir.glob(component_root.join("**/component.rb")) +
      Dir.glob(component_root.join("**/*_component.rb"))
    ).uniq.sort

    files.reject! { |path| path.end_with?("base_component.rb") }

    files.filter_map do |file_path|
      build_component_entry(file_path, component_root)
    end
  end

  def paginated_infinite_records
    if dummy_data_available?
      records = DummyDatum.recent
      return pagy(records, items: 10) if records.count > 10
    end

    pagy_array(infinite_demo_records, items: 10)
  rescue ActiveRecord::StatementInvalid
    pagy_array(infinite_demo_records, items: 10)
  end

  def dummy_data_available?
    DummyDatum.table_exists?
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    false
  end

  def infinite_demo_records
    @infinite_demo_records ||= Array.new(75) do |i|
      OpenStruct.new(
        id: i + 1,
        name: "Demo User #{i + 1}",
        email: "demo.user#{i + 1}@example.com",
        status: %w[active inactive pending archived].sample,
        category: %w[engineering marketing sales product support].sample,
        views_count: rand(120..9_900),
        published_at: rand(90).days.ago
      )
    end
  end

  def build_component_entry(file_path, component_root)
    relative_file_path = Pathname.new(file_path).relative_path_from(component_root).to_s
    component_path = relative_file_path.delete_suffix(".rb")
    class_name = component_class_name(component_path)
    component_class = class_name.safe_constantize

    {
      name: class_name.delete_prefix("FlatPack::"),
      description: component_description(component_path),
      variables: component_class ? initializer_variables(component_class) : ["(unavailable)"],
      methods: component_class ? public_component_methods(component_class) : ["(unavailable)"]
    }
  end

  def component_class_name(component_path)
    "FlatPack::#{component_path.split("/").map(&:camelize).join("::")}"
  end

  def component_description(component_path)
    component_key = component_path.split("/").first
    @component_description_cache ||= {}
    return @component_description_cache[component_key] if @component_description_cache.key?(component_key)

    doc_path = FlatPack::Engine.root.join("docs/components/#{component_key}.md")

    @component_description_cache[component_key] = if File.exist?(doc_path)
      first_paragraph_from_markdown(doc_path)
    else
      "No dedicated documentation available for this component yet."
    end
  end

  def first_paragraph_from_markdown(path)
    lines = File.readlines(path, chomp: true)
    in_code_block = false
    paragraph_lines = []

    lines.each do |line|
      stripped = line.strip

      if stripped.start_with?("```")
        in_code_block = !in_code_block
        next
      end

      next if in_code_block
      next if stripped.start_with?("#")
      next if stripped.start_with?("|")

      if stripped.empty?
        break if paragraph_lines.any?
        next
      end

      paragraph_lines << stripped
    end

    paragraph_lines.join(" ").presence || "No description available."
  end

  def initializer_variables(component_class)
    component_class
      .instance_method(:initialize)
      .parameters
      .filter_map do |type, name|
        case type
        when :keyreq
          "#{name} (required)"
        when :key
          name.to_s
        when :keyrest
          "**#{name}"
        end
      end
      .presence || ["(none)"]
  end

  def public_component_methods(component_class)
    component_class
      .public_instance_methods(false)
      .map(&:to_s)
      .reject { |method_name| method_name.start_with?("_") }
      .sort
      .presence || ["(none)"]
  end

  def sort_users(users, sort_column, direction)
    return users unless sort_column.present?

    valid_columns = %w[id name email status created_at]
    return users unless valid_columns.include?(sort_column)

    direction = (direction == "desc") ? "desc" : "asc"

    sorted = users.sort_by do |user|
      value = user.public_send(sort_column)
      value.nil? ? "" : value
    end

    (direction == "desc") ? sorted.reverse : sorted
  end

  def reorder_payload
    payload = params.require(:reorder).permit(
      :resource,
      :strategy,
      :version,
      scope: {},
      items: %i[id position]
    )

    {
      resource: payload[:resource].presence || "demo_table_rows",
      strategy: payload[:strategy].presence || "dense_integer",
      version: payload[:version],
      scope: payload[:scope] || {},
      items: payload[:items] || []
    }
  end

  def ensure_demo_table_rows!
    return unless demo_table_rows_table_exists?
    return if DemoTableRow.where(list_key: DemoTableRow::DEFAULT_LIST_KEY).exists?

    rows = [
      {name: "Backlog grooming", status: "pending", priority: "low"},
      {name: "Design QA", status: "active", priority: "high"},
      {name: "API integration", status: "active", priority: "medium"},
      {name: "Release checklist", status: "inactive", priority: "medium"},
      {name: "Retrospective prep", status: "pending", priority: "low"}
    ]

    timestamp = Time.current
    rows_to_insert = rows.each_with_index.map do |row, index|
      {
        list_key: DemoTableRow::DEFAULT_LIST_KEY,
        name: row[:name],
        status: row[:status],
        priority: row[:priority],
        position: index + 1,
        created_at: timestamp,
        updated_at: timestamp
      }
    end

    DemoTableRow.insert_all(rows_to_insert, unique_by: :index_demo_table_rows_on_list_key_and_position)
  end

  def demo_table_version(scope = {list_key: DemoTableRow::DEFAULT_LIST_KEY})
    DemoTableRow.where(scope).maximum(:updated_at)&.to_f&.to_s || "0"
  end

  def demo_table_rows_table_exists?
    DemoTableRow.table_exists?
  end

  def chat_tables_available?
    ChatGroup.table_exists? && ChatMessage.table_exists?
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    false
  end

  def ensure_chat_demo_messages!
    group = ChatGroup.find_or_create_by!(name: "Design Team")
    return if group.chat_messages.exists?

    timeline = [
      {sender_name: "Mina", body: "I pushed the homepage copy updates. Can someone review?", state: "read"},
      {sender_name: "You", body: "Reviewed. Tone is solid — can you also add a shorter hero variant for mobile?", state: "read"},
      {sender_name: "Sam", body: "I added both hero lengths and updated CTA spacing.", state: "read"},
      {sender_name: "Alex", body: "Noted. I will sync this with the launch checklist.", state: "read"},
      {sender_name: "You", body: "Can we tighten spacing in the testimonial section too?", state: "read"},
      {sender_name: "Mina", body: "Done. Spacing is now 20px desktop and 16px mobile.", state: "read"},
      {sender_name: "Sam", body: "I updated button hover states to match the latest token values.", state: "read"},
      {sender_name: "You", body: "Great. Please also confirm dark mode contrast for secondary text.", state: "read"},
      {sender_name: "Alex", body: "Tracking sheet is ready. I will post click-through updates in this chat group.", state: "read"},
      {sender_name: "Mina", body: "Hero fallback headline for mobile has been added.", state: "read"},
      {sender_name: "You", body: "Thanks. Let us freeze copy after one last proofread.", state: "read"},
      {sender_name: "Sam", body: "Proofread complete. Fixed two punctuation issues.", state: "read"},
      {sender_name: "Alex", body: "Pre-launch analytics events are now validated in staging.", state: "read"},
      {sender_name: "You", body: "Please share a screenshot of the updated hero on small screens.", state: "read"},
      {sender_name: "Mina", body: "Shared in Figma and attached in the release notes.", state: "read"},
      {sender_name: "Sam", body: "Footer links were re-ordered per legal review.", state: "read"},
      {sender_name: "You", body: "Can we reduce the CTA shadow to keep it subtle?", state: "read"},
      {sender_name: "Mina", body: "Yes, reduced. It now uses the lower elevation token.", state: "read"},
      {sender_name: "Alex", body: "Launch window reminder: 3:00 PM with rollback checkpoint at 3:30.", state: "read"},
      {sender_name: "You", body: "Perfect. I will stay online through post-launch validation.", state: "read"},
      {sender_name: "Sam", body: "I added status badges for experiment variants in the dashboard.", state: "read"},
      {sender_name: "Mina", body: "Final visual QA pass is complete from my side.", state: "read"},
      {sender_name: "Alex", body: "Monitoring alerts are configured and tested.", state: "read"},
      {sender_name: "You", body: "All right, locking this version and moving to ship.", state: "read"}
    ]

    now = Time.current
    rows = timeline.each_with_index.map do |entry, index|
      {
        chat_group_id: group.id,
        sender_name: entry[:sender_name],
        body: entry[:body],
        state: entry[:state],
        created_at: now - (timeline.length - index).minutes,
        updated_at: now - (timeline.length - index).minutes
      }
    end

    ChatMessage.insert_all(rows)
  end

  def recent_chat_messages(chat_group)
    return [] unless chat_group

    recent_ids = chat_group.chat_messages
      .order(created_at: :desc, id: :desc)
      .limit(10)
      .select(:id)

    chat_group.chat_messages.where(id: recent_ids).chronological
  end

  def movable_cards_list_key
    "grid-movable-cards-demo"
  end

  def ensure_demo_movable_cards!
    return unless demo_table_rows_table_exists?
    return if DemoTableRow.where(list_key: movable_cards_list_key).exists?

    cards = [
      {name: "Weekly roadmap", status: "active", priority: "high"},
      {name: "Design review", status: "pending", priority: "medium"},
      {name: "Customer feedback", status: "active", priority: "high"},
      {name: "Release notes", status: "inactive", priority: "low"},
      {name: "Sprint retrospective", status: "pending", priority: "medium"},
      {name: "Backlog cleanup", status: "active", priority: "low"}
    ]

    timestamp = Time.current
    rows_to_insert = cards.each_with_index.map do |card, index|
      {
        list_key: movable_cards_list_key,
        name: card[:name],
        status: card[:status],
        priority: card[:priority],
        position: index + 1,
        created_at: timestamp,
        updated_at: timestamp
      }
    end

    DemoTableRow.insert_all(rows_to_insert, unique_by: :index_demo_table_rows_on_list_key_and_position)
  end

  def searchable_items
    [
      {title: "Overview", description: "FlatPack component library home", url: demo_path},
      {title: "Buttons", description: "Button variants and dropdown examples", url: demo_buttons_path},
      {title: "Forms", description: "Form submit patterns with HTTP methods", url: demo_forms_path},
      {title: "Text Input", description: "Single-line text input examples", url: demo_forms_text_input_path},
      {title: "Password Input", description: "Masked text input with visibility toggle", url: demo_forms_password_input_path},
      {title: "Email Input", description: "Email-specific input examples", url: demo_forms_email_input_path},
      {title: "Phone Input", description: "Telephone input examples", url: demo_forms_phone_input_path},
      {title: "Search Input", description: "Search field with helper affordances", url: demo_forms_search_input_path},
      {title: "URL Input", description: "URL input examples", url: demo_forms_url_input_path},
      {title: "Text Area", description: "Multiline text input examples", url: demo_forms_text_area_path},
      {title: "Number Input", description: "Numeric input with constraints", url: demo_forms_number_input_path},
      {title: "Date Input", description: "Date picker input examples", url: demo_forms_date_input_path},
      {title: "File Input", description: "File upload input examples", url: demo_forms_file_input_path},
      {title: "Checkbox", description: "Checkbox input examples", url: demo_forms_checkbox_path},
      {title: "Radio Group", description: "Single-choice radio group examples", url: demo_forms_radio_group_path},
      {title: "Select", description: "Dropdown select input examples", url: demo_forms_select_path},
      {title: "Switch", description: "Toggle switch input examples", url: demo_forms_switch_path},
      {title: "Range Input", description: "Slider input with live value", url: demo_range_input_path},
      {title: "Combined Form", description: "Full form with multiple input types", url: demo_forms_combined_path},
      {title: "Tables", description: "Basic table examples with formatting and actions", url: demo_tables_basic_path},
      {title: "Tables: Basic", description: "Basic table examples with formatting and actions", url: demo_tables_basic_path},
      {title: "Tables: Empty", description: "Empty state table rendering with no rows", url: demo_tables_empty_path},
      {title: "Tables: Sortable", description: "Sortable columns with Turbo frame updates", url: demo_tables_sortable_path},
      {title: "Tables: Draggable", description: "Drag-and-drop row reordering with persistence", url: demo_tables_draggable_path},
      {title: "Cards", description: "Composed card layouts", url: demo_cards_path},
      {title: "Alerts", description: "Status and feedback messages", url: demo_alerts_path},
      {title: "Badges", description: "Label and status indicators", url: demo_badges_path},
      {title: "Breadcrumbs", description: "Hierarchical navigation trails", url: demo_breadcrumbs_path},
      {title: "Top Nav", description: "Header layout with left, center, and right slots", url: demo_navbar_path},
      {title: "Search", description: "Reusable search component with live results", url: demo_search_path},
      {title: "Sidebar Layout", description: "Sidebar layout shell with left/right positioning", url: demo_sidebar_layout_path},
      {title: "Sidebar Basic", description: "Basic sidebar with header, items, and footer", url: demo_sidebar_basic_path},
      {title: "Sidebar Header", description: "Header configurations for sidebar branding and actions", url: demo_sidebar_header_path},
      {title: "Sidebar Footer", description: "Footer patterns for status, metadata, and account actions", url: demo_sidebar_footer_path},
      {title: "Sidebar with Badges", description: "Sidebar navigation items with badges", url: demo_sidebar_badges_path},
      {title: "Sidebar Grouped", description: "Sidebar navigation with grouped items", url: demo_sidebar_grouped_path},
      {title: "Sidebar Collapsible", description: "Sidebar groups that expand and collapse", url: demo_sidebar_collapsible_path},
      {title: "Sidebar Collapsed", description: "Icon-only collapsed sidebar pattern", url: demo_sidebar_collapsed_path},
      {title: "Sidebar Complete", description: "Full-featured sidebar composition", url: demo_sidebar_complete_path},
      {title: "Modals", description: "Dialog overlays with focus trap", url: demo_modals_path},
      {title: "Popovers", description: "Click-triggered floating content", url: demo_popovers_path},
      {title: "Tooltips", description: "Hover/focus tooltips", url: demo_tooltips_path},
      {title: "Tabs", description: "Underlined tabs with keyboard navigation", url: demo_tabs_path},
      {title: "Pills", description: "Pill-style tabs with shared accessibility behavior", url: demo_tabs_pills_path},
      {title: "Stacked Pills", description: "Vertical pill-style tabs with two-column layout on larger screens", url: demo_tabs_stacked_pills_path},
      {title: "Toasts", description: "Auto-dismissing notifications", url: demo_toasts_path},
      {title: "Page Title", description: "Page title with optional subtitle", url: demo_page_header_path},
      {title: "Quote", description: "Blockquote and citation text examples", url: demo_text_quote_path},
      {title: "Empty State", description: "User-friendly empty states", url: demo_empty_state_path},
      {title: "Grid", description: "Responsive grid layouts", url: demo_grid_path},
      {title: "Grid: Two Columns", description: "Two-column layout with one card in each column", url: demo_grid_two_columns_path},
      {title: "Grid: Movable Cards", description: "Draggable card grid with persisted ordering", url: demo_grid_movable_cards_path},
      {title: "Pagination", description: "Page navigation with Pagy", url: demo_pagination_path},
      {title: "Charts", description: "Data visualization with ApexCharts", url: demo_charts_path},
      {title: "Code Blocks", description: "Reusable snippets for demo pages", url: demo_code_blocks_path}
    ]
  end

  def load_table_demo_data
    ensure_demo_table_rows!

    @users = Array.new(20) do |i|
      OpenStruct.new(
        id: i + 1,
        name: "User #{i + 1}",
        email: "user#{i + 1}@example.com",
        status: %w[active inactive pending].sample,
        created_at: rand(30).days.ago,
        category: %w[Technology Business Marketing Design].sample,
        views_count: rand(100..5_000),
        published_at: rand(60).days.ago
      )
    end

    @sorted_users = sort_users(@users.dup, params[:sort], params[:direction])
    @demo_table_rows = demo_table_rows_table_exists? ? DemoTableRow.where(list_key: DemoTableRow::DEFAULT_LIST_KEY).ordered : []
    @demo_table_version = demo_table_rows_table_exists? ? demo_table_version : "0"
  end
end
