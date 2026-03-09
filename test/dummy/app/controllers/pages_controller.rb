# frozen_string_literal: true

require "ostruct"
require "pagy"
require "pagy/extras/array"

class PagesController < ApplicationController
  include Pagy::Backend

  DEMO_CHAT_FILE_DOWNLOADS = {
    "launch-plan" => {
      filename: "launch-plan.pdf",
      content_type: "application/pdf",
      body: <<~PDF
        %PDF-1.4
        1 0 obj
        << /Type /Catalog >>
        endobj
        Demo launch plan PDF for FlatPack chat file message previews.
      PDF
    },
    "qa-checklist" => {
      filename: "qa-checklist.csv",
      content_type: "text/csv",
      body: <<~CSV
        item,status,owner
        Release smoke test,complete,QA
        Accessibility spot check,in_progress,Design Systems
        Production sign-off,pending,Release Team
      CSV
    }
  }.freeze

  DEMO_THEME_TOKEN_MAPPINGS = [
    {action: /\Abuttons\z/, title: "Buttons", patterns: [/\A--button-/]},
    {action: /\Aalerts\z/, title: "Alerts", patterns: [/\A--alert-/]},
    {action: /\Abadges\z/, title: "Badges", patterns: [/\A--badge-/]},
    {action: /\Achips\z/, title: "Chips", patterns: [/\A--chip-/]},
    {action: /\Acards\z/, title: "Cards", patterns: [/\A--card-/]},
    {action: /\Abreadcrumbs\z/, title: "Breadcrumbs", patterns: [/\A--breadcrumb-/]},
    {action: /\Anavbar\z/, title: "Top Nav", patterns: [/\A--top-nav-/]},
    {action: /\Asidebar(_.*)?\z/, title: "Sidebar", patterns: [/\A--sidebar-/]},
    {action: /\Amodals\z/, title: "Modals", patterns: [/\A--modal-/]},
    {action: /\Apopovers\z/, title: "Popovers", patterns: [/\A--popover-/]},
    {action: /\Atooltips\z/, title: "Tooltips", patterns: [/\A--tooltip-/]},
    {action: /\Atabs(_.*)?\z/, title: "Tabs", patterns: [/\A--tabs-/]},
    {action: /\Atoasts\z/, title: "Toasts", patterns: [/\A--toast-/]},
    {action: /\Atext_quote\z/, title: "Quote", patterns: [/\A--quote-/]},
    {action: /\Acode_blocks\z/, title: "Code Blocks", patterns: [/\A--code-block-/]},
    {action: /\Acarousel\z/, title: "Carousel", patterns: [/\A--carousel-/]},
    {action: /\Aavatars\z/, title: "Avatars", patterns: [/\A--avatar-/]},
    {action: /\Acomments\z/, title: "Comments", patterns: [/\A--comments-/]},
    {action: /\Achat(_.*)?\z/, title: "Chat", patterns: [/\A--chat-/]},
    {action: /\Atables(_.*)?\z/, title: "Table", patterns: [/\A--table-/]},
    {action: /\A(forms(_.*)?|inputs|range_input)\z/, title: "Form Controls", patterns: [/\A--form-control-/]},
    {action: /\Aforms_switch\z/, title: "Form Controls & Switch", patterns: [/\A--form-control-/, /\A--switch-/]},
    {action: /\Aforms_checkbox\z/, title: "Form Controls & Checkbox", patterns: [/\A--form-control-/, /\A--checkbox-/]},
    {action: /\Acollapse\z/, title: "Collapse", patterns: [/\A--collapse-/]},
    {action: /\Askeletons\z/, title: "Skeleton", patterns: [/\A--skeleton-/]},
    {action: /\Atimeline\z/, title: "Timeline", patterns: [/\A--timeline-/]},
    {action: /\Alist\z/, title: "List", patterns: [/\A--list-item-/]}
  ].freeze

  before_action :load_table_demo_data, only: %i[tables_basic tables_sortable tables_draggable]
  before_action :load_demo_theme_tokens

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

  def picker
    @picker_demo_items = picker_demo_items
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

  def picker_results
    query = params[:q].to_s.strip.downcase
    kinds = params[:kinds].to_s.split(",").map(&:strip).presence

    results = picker_demo_items
    if kinds.present?
      results = results.select { |item| kinds.include?(item[:kind]) }
    end

    if query.present?
      results = results.select do |item|
        [item[:label], item[:name], item[:content_type], item[:kind]].compact.any? { |value| value.downcase.include?(query) }
      end
    end

    render json: {
      items: results.first(30).map { |item| picker_item_payload(item) }
    }
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
    @reply_target_id = params[:reply_to].presence&.to_i

    if comments_table_available?
      @comments_table_available = true
      ensure_comments_demo_data!

      all_comments = DemoComment.order(:created_at, :id).to_a
      @comments_by_parent_id = all_comments.group_by(&:parent_comment_id)
      @root_comments = @comments_by_parent_id[nil] || []
      @comments_count = all_comments.length
    else
      @comments_table_available = false
      @comments_by_parent_id = {}
      @root_comments = []
      @comments_count = 0
    end
  end

  def chat_demo
    history_limit = 10
    @chat_attachment_picker_items = chat_attachment_picker_items

    if chat_tables_available?
      ensure_chat_demo_items!
      @chat_group_summaries = build_chat_group_summaries
      @chat_group = selected_chat_group(@chat_group_summaries)
      mark_active_chat_group!(@chat_group_summaries, @chat_group)
      @chat_items = recent_chat_items(@chat_group, limit: history_limit)

      oldest_item_id = @chat_items.first&.id
      @chat_history_has_more = oldest_item_id.present? && @chat_group && @chat_group.chat_items.where("id < ?", oldest_item_id).exists?
      @chat_history_url = @chat_group ? demo_chat_group_messages_path(@chat_group) : nil
    else
      @chat_group = nil
      @chat_group_summaries = []
      @chat_items = []
      @chat_history_has_more = false
      @chat_history_url = nil
    end
    @chat_history_limit = history_limit
  end

  def chat_layout
  end

  def chat_panel
  end

  def chat_message_list
  end

  def chat_message_group
  end

  def chat_sent_message
  end

  def chat_received_message
  end

  def chat_file_message
  end

  def chat_file_download
    file = DEMO_CHAT_FILE_DOWNLOADS[params[:slug].to_s]
    raise ActionController::RoutingError, "Not Found" unless file

    send_data(
      file.fetch(:body),
      filename: file.fetch(:filename),
      type: file.fetch(:content_type),
      disposition: :attachment
    )
  end

  def chat_images
    @chat_images_single_incoming_slides = chat_images_single_incoming_slides
    @chat_images_single_outgoing_slides = chat_images_single_outgoing_slides
    @chat_images_incoming_slides = chat_images_incoming_slides
    @chat_images_outgoing_slides = chat_images_outgoing_slides
  end

  def chat_system_message
  end

  def chat_inbox_row
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

  def carousel
    @carousel_slides = carousel_demo_slides
    @carousel_single_slide = carousel_demo_single_slide
    @carousel_notes = [
      "Uses FlatPack::Carousel::Component with image, video, and component-rendered HTML slides.",
      "Demonstrates autoplay, loop, indicators, controls, and thumbnail navigation.",
      "Image slides enable lightbox by default and can opt out per slide with lightbox: false.",
      "Uses secure defaults for rich content and supports keyboard plus touch interactions."
    ]
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
    @active_list_demo_item = params[:active_item].to_s
    valid_items = %w[buttons tables chat_demo search]
    @active_list_demo_item = "buttons" unless valid_items.include?(@active_list_demo_item)
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
    ChatGroup.table_exists? && ChatItem.table_exists?
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    false
  end

  def comments_table_available?
    DemoComment.table_exists?
  rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
    false
  end

  def ensure_comments_demo_data!
    return unless comments_table_available?
    return if DemoComment.exists?

    alice = DemoComment.create!(
      author_name: "Alice Johnson",
      author_meta: "Software Engineer",
      body: "This is a really great feature! I've been waiting for something like this."
    )

    bob = DemoComment.create!(
      author_name: "Bob Smith",
      body: "I agree. This will save us a lot of time."
    )

    DemoComment.create!(
      parent_comment: alice,
      author_name: "Charlie Brown",
      body: "Same here. Can we also add a quick start guide?"
    )

    DemoComment.create!(
      parent_comment: bob,
      author_name: "Diana Prince",
      body: "Good call. I can draft the first pass this week."
    )
  end

  def ensure_chat_demo_items!
    normalize_chat_demo_sender_names!

    design_team_timeline = [
      {sender_name: "Mina Cho", body: "I pushed the homepage copy updates. Can someone review?", state: "read"},
      {sender_name: "You", body: "Reviewed. Tone is solid — can you also add a shorter hero variant for mobile?", state: "read"},
      {sender_name: "Sam Lee", body: "I added both hero lengths and updated CTA spacing.", state: "read"},
      {sender_name: "Alex Rivera", body: "Noted. I will sync this with the launch checklist.", state: "read"},
      {sender_name: "You", body: "Can we tighten spacing in the testimonial section too?", state: "read"},
      {sender_name: "Mina Cho", body: "Done. Spacing is now 20px desktop and 16px mobile.", state: "read"},
      {sender_name: "Sam Lee", body: "I updated button hover states to match the latest token values.", state: "read"},
      {sender_name: "You", body: "Great. Please also confirm dark mode contrast for secondary text.", state: "read"},
      {sender_name: "Alex Rivera", body: "Tracking sheet is ready. I will post click-through updates in this chat group.", state: "read"},
      {sender_name: "Mina Cho", body: "Hero fallback headline for mobile has been added.", state: "read"},
      {sender_name: "You", body: "Thanks. Let us freeze copy after one last proofread.", state: "read"},
      {sender_name: "Sam Lee", body: "Proofread complete. Fixed two punctuation issues.", state: "read"},
      {sender_name: "Alex Rivera", body: "Pre-launch analytics events are now validated in staging.", state: "read"},
      {sender_name: "You", body: "Please share a screenshot of the updated hero on small screens.", state: "read"},
      {sender_name: "Mina Cho", body: "Shared in Figma and attached in the release notes.", state: "read"},
      {sender_name: "Sam Lee", body: "Footer links were re-ordered per legal review.", state: "read"},
      {sender_name: "You", body: "Can we reduce the CTA shadow to keep it subtle?", state: "read"},
      {sender_name: "Mina Cho", body: "Yes, reduced. It now uses the lower elevation token.", state: "read"},
      {sender_name: "Alex Rivera", body: "Launch window reminder: 3:00 PM with rollback checkpoint at 3:30.", state: "read"},
      {sender_name: "You", body: "Perfect. I will stay online through post-launch validation.", state: "read"},
      {sender_name: "Sam Lee", body: "I added status badges for experiment variants in the dashboard.", state: "read"},
      {sender_name: "Mina Cho", body: "Final visual QA pass is complete from my side.", state: "read"},
      {sender_name: "Alex Rivera", body: "Monitoring alerts are configured and tested.", state: "read"},
      {
        sender_name: "You",
        body: nil,
        state: "read",
        attachments: [
          {kind: "image", name: "hero-mobile-1.png", content_type: "image/png", byte_size: 182_300},
          {kind: "image", name: "hero-mobile-2.png", content_type: "image/png", byte_size: 194_100},
          {kind: "image", name: "hero-mobile-3.png", content_type: "image/png", byte_size: 189_000}
        ]
      },
      {sender_name: "You", body: "All right, locking this version and moving to ship.", state: "read"}
    ]

    product_updates_timeline = [
      {sender_name: "Priya", body: "Roadmap draft is up with two candidate launch windows.", state: "read"},
      {sender_name: "You", body: "Please tag blockers by priority before tomorrow standup.", state: "read"},
      {sender_name: "Noah", body: "Done. Added risk notes for onboarding copy and billing events.", state: "read"},
      {sender_name: "Priya", body: "Thanks — sharing revised timeline after lunch.", state: "read"}
    ]

    launch_ops_timeline = [
      {sender_name: "Jordan", body: "Status page template is ready for launch-day updates.", state: "read"},
      {sender_name: "You", body: "Great. Keep incident contact list pinned in this chat group.", state: "read"},
      {sender_name: "Riley", body: "On-call schedule confirmed through the weekend.", state: "read"},
      {sender_name: "Jordan", body: "Dry run starts at 2:30 PM. I will post checkpoints here.", state: "read"}
    ]

    seed_chat_group_timeline!(
      ChatGroup.find_or_create_by!(name: "Design Team"),
      design_team_timeline,
      offset_minutes: 0
    )

    seed_chat_group_timeline!(
      ChatGroup.find_or_create_by!(name: "Product Updates"),
      product_updates_timeline,
      offset_minutes: 45
    )

    seed_chat_group_timeline!(
      ChatGroup.find_or_create_by!(name: "Launch Ops"),
      launch_ops_timeline,
      offset_minutes: 90
    )
  end

  def normalize_chat_demo_sender_names!
    {
      "Alex" => "Alex Rivera",
      "Mina" => "Mina Cho",
      "Sam" => "Sam Lee"
    }.each do |legacy_name, canonical_name|
      ChatItem.where(sender_name: legacy_name).update_all(sender_name: canonical_name, updated_at: Time.current)
    end
  end

  def picker_demo_items
    [
      {
        id: "asset-homepage-hero",
        kind: "image",
        name: "homepage-hero-v2.png",
        content_type: "image/png",
        byte_size: 312_400,
        label: "Homepage Hero",
        thumbnail_url: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=640&h=360&fit=crop",
        meta: "Homepage refresh"
      },
      {
        id: "asset-checkout-mobile",
        kind: "image",
        name: "checkout-mobile-a.png",
        content_type: "image/png",
        byte_size: 198_250,
        label: "Checkout Mobile",
        thumbnail_url: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=640&h=360&fit=crop",
        meta: "Flow variant A"
      },
      {
        id: "asset-pricing-grid",
        kind: "image",
        name: "pricing-grid-rev3.jpg",
        content_type: "image/jpeg",
        byte_size: 421_900,
        label: "Pricing Grid",
        thumbnail_url: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=640&h=360&fit=crop",
        meta: "Desktop layout"
      },
      {
        id: "asset-funnel-sketch",
        kind: "image",
        name: "onboarding-funnel-sketch.jpg",
        content_type: "image/jpeg",
        byte_size: 287_210,
        label: "Onboarding Funnel",
        thumbnail_url: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=640&h=360&fit=crop",
        meta: "Journey board"
      },
      {
        id: "asset-launch-checklist",
        kind: "file",
        name: "launch-readiness-checklist.pdf",
        content_type: "application/pdf",
        byte_size: 96_800,
        label: "Launch Checklist",
        meta: "PDF"
      },
      {
        id: "asset-experiment-results",
        kind: "file",
        name: "experiment-results-q1.csv",
        content_type: "text/csv",
        byte_size: 43_200,
        label: "Experiment Results",
        meta: "CSV"
      },
      {
        id: "asset-handoff-notes",
        kind: "file",
        name: "handoff-notes.zip",
        content_type: "application/zip",
        byte_size: 1_204_800,
        label: "Handoff Notes",
        meta: "ZIP"
      },
      {
        id: "asset-quarterly-plan",
        kind: "file",
        name: "quarterly-launch-plan.docx",
        content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        byte_size: 212_640,
        label: "Quarterly Launch Plan",
        meta: "DOCX"
      }
    ]
  end

  def chat_attachment_picker_items
    picker_demo_items.first(6)
  end

  def seed_chat_group_timeline!(group, timeline, offset_minutes: 0)
    return if group.chat_items.exists?

    now = Time.current
    timeline.each_with_index do |entry, index|
      minutes_ago = (timeline.length - index) + offset_minutes

      item = group.chat_items.build(
        chat_group_id: group.id,
        sender_name: entry[:sender_name],
        body: entry[:body],
        state: entry[:state],
        submitted_at: nil,
        created_at: now - minutes_ago.minutes,
        updated_at: now - minutes_ago.minutes
      )

      Array(entry[:attachments]).each_with_index do |attachment, attachment_index|
        item.chat_item_attachments.build(
          kind: attachment[:kind],
          name: attachment[:name],
          content_type: attachment[:content_type],
          byte_size: attachment[:byte_size],
          position: attachment_index
        )
      end

      item.save!
    end
  end

  def build_chat_group_summaries
    ChatGroup.order(:name).map do |group|
      latest_item = group.chat_items.order(created_at: :desc, id: :desc).first

      {
        chat_group: group,
        initials: chat_group_initials(group),
        avatar_items: chat_group_avatar_items(group),
        latest_sender: latest_item&.sender_name,
        latest_preview: chat_group_preview(latest_item),
        latest_at: latest_item&.created_at || group.updated_at || group.created_at,
        unread_count: demo_chat_group_unread_count(group),
        active: false
      }
    end.sort_by { |summary| summary[:latest_at] || Time.zone.at(0) }.reverse
  end

  def selected_chat_group(summaries)
    requested_group_id = params[:chat_group_id].presence&.to_i

    requested_group = if requested_group_id
      summaries.find { |summary| summary[:chat_group].id == requested_group_id }&.dig(:chat_group)
    end

    requested_group || summaries.first&.dig(:chat_group)
  end

  def mark_active_chat_group!(summaries, active_chat_group)
    active_chat_group_id = active_chat_group&.id

    summaries.each do |summary|
      summary[:active] = summary[:chat_group].id == active_chat_group_id
    end
  end

  def chat_group_initials(group)
    initials = group.name.to_s.split.map { |part| part[0] }.join.upcase
    initials.first(2)
  end

  def chat_group_avatar_items(group)
    participant_names = group.chat_items
      .order(created_at: :desc, id: :desc)
      .pluck(:sender_name)
      .map { |name| name.to_s.strip }
      .reject(&:blank?)
      .uniq

    # Prefer showing other members first when available, but keep "You" when relevant.
    non_self, self_names = participant_names.partition { |name| !name.casecmp?("You") }
    ordered_names = non_self + self_names

    items = ordered_names.map do |name|
      {
        name: name,
        initials: participant_initials(name)
      }
    end

    return items if items.any?

    [{name: group.name, initials: chat_group_initials(group)}]
  end

  def participant_initials(name)
    initials = name.to_s.split.map { |part| part[0] }.join.upcase
    initials.first(2)
  end

  def chat_group_preview(item)
    return "No messages yet" unless item

    return item.body if item.body.present?
    return "Sent #{item.chat_item_attachments.size} attachments" if item.chat_item_attachments.any?

    "Sent an update"
  end

  def demo_chat_group_unread_count(group)
    # In this demo inbox, badge count reflects total messages in the chat group.
    group.chat_items.count
  end

  def recent_chat_items(chat_group, limit: 10)
    return [] unless chat_group

    recent_ids = chat_group.chat_items
      .order(created_at: :desc, id: :desc)
      .limit(limit)
      .select(:id)

    chat_group.chat_items
      .includes(:chat_item_attachments)
      .where(id: recent_ids)
      .chronological
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
      {title: "Theme Variables", description: "Theme token values and CSS variable reference", url: themes_path},
      {title: "System theme", description: "System color scheme demo", url: theme_demo_path(theme: "system")},
      {title: "Light theme", description: "Light color scheme demo", url: theme_demo_path(theme: "light")},
      {title: "Dark theme", description: "Dark color scheme demo", url: theme_demo_path(theme: "dark")},
      {title: "Ocean theme", description: "Ocean color scheme demo", url: theme_demo_path(theme: "ocean")},
      {title: "Rounded theme", description: "Rounded theme demo", url: theme_demo_path(theme: "rounded")},
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
      {title: "Chips", description: "Compact filter and tag components", url: demo_chips_path},
      {title: "Breadcrumbs", description: "Hierarchical navigation trails", url: demo_breadcrumbs_path},
      {title: "Top Nav", description: "Header layout with left, center, and right slots", url: demo_navbar_path},
      {title: "Search", description: "Reusable search component with live results", url: demo_search_path},
      {title: "Picker", description: "Reusable file and image picker for any workflow", url: demo_picker_path},
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
      {title: "Infinite Scroll", description: "Infinite scrolling pagination patterns", url: demo_pagination_infinite_path},
      {title: "Charts", description: "Data visualization with ApexCharts", url: demo_charts_path},
      {title: "Code Blocks", description: "Reusable snippets for demo pages", url: demo_code_blocks_path},
      {title: "Avatars", description: "Avatar and avatar group examples", url: demo_avatars_path},
      {title: "Comments", description: "Comments threads and reply composer patterns", url: demo_comments_path},
      {title: "Chat Demo", description: "End-to-end chat demo experience", url: demo_chat_demo_path},
      {title: "Chat Layout", description: "Two-panel chat layout examples", url: demo_chat_layout_path},
      {title: "Chat Panel", description: "Chat panel container patterns", url: demo_chat_panel_path},
      {title: "Chat Message List", description: "Chat message list patterns", url: demo_chat_message_list_path},
      {title: "Chat Message Group", description: "Grouped chat message patterns", url: demo_chat_message_group_path},
      {title: "Chat Sent Message", description: "Outgoing message examples", url: demo_chat_sent_message_path},
      {title: "Chat Received Message", description: "Incoming message examples", url: demo_chat_received_message_path},
      {title: "Chat File Message", description: "File attachment message examples", url: demo_chat_file_message_path},
      {title: "Chat Images", description: "Single and multi-image chat message examples with carousel lightbox", url: demo_chat_images_path},
      {title: "Chat System Message", description: "System message examples", url: demo_chat_system_message_path},
      {title: "Chat Attachment", description: "Attachment component examples", url: demo_chat_attachment_path},
      {title: "Chat Date Divider", description: "Date divider component examples", url: demo_chat_date_divider_path},
      {title: "Chat Typing Indicator", description: "Typing indicator component examples", url: demo_chat_typing_indicator_path},
      {title: "Chat Composer", description: "Composer input and action patterns", url: demo_chat_composer_path},
      {title: "Chat Textarea", description: "Chat textarea component examples", url: demo_chat_textarea_path},
      {title: "Chat Send Button", description: "Send button component examples", url: demo_chat_send_button_path},
      {title: "Carousel", description: "FlatPack carousel demo with mixed media and navigation controls", url: demo_carousel_path},
      {title: "Progress", description: "Progress indicators and loading states", url: demo_progress_path},
      {title: "Collapse", description: "Expandable and collapsible content patterns", url: demo_collapse_path},
      {title: "Skeletons", description: "Skeleton loading placeholders", url: demo_skeletons_path},
      {title: "List", description: "List component demos and selectable rows", url: demo_list_path},
      {title: "Timeline", description: "Chronological timeline layouts", url: demo_timeline_path},
      {title: "Mobile", description: "Mobile demo index", url: mobile_path},
      {title: "Bottom Nav", description: "Mobile bottom navigation demo", url: mobile_bottom_nav_path}
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

  def picker_item_payload(item)
    {
      id: item[:id],
      kind: item[:kind],
      label: item[:label],
      name: item[:name],
      contentType: item[:content_type],
      byteSize: item[:byte_size],
      thumbnailUrl: item[:thumbnail_url],
      meta: item[:meta],
      payload: item[:payload] || {}
    }.compact
  end

  def carousel_demo_slides
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1600&h=900&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=320&h=180&fit=crop",
        alt: "Product analytics dashboard",
        caption: "Analytics dashboard concept",
        lightbox: true
      },
      {
        type: :video,
        src: "https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4",
        poster: "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1600&h=900&fit=crop",
        caption: "Product teaser clip"
      },
      {
        type: :html,
        caption: "Email capture form",
        html: ApplicationController.render(
          renderable: FlatPack::TextInput::Component.new(
            name: "lead[email]",
            label: "Work email",
            placeholder: "you@company.com",
            required: true,
            class: "w-full"
          ),
          layout: false
        )
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1600&h=900&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=320&h=180&fit=crop",
        alt: "Planning workshop board",
        caption: "Planning workshop board",
        lightbox: false
      }
    ]
  end

  def carousel_demo_single_slide
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=1600&h=900&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=320&h=180&fit=crop",
        alt: "Single slide gallery preview",
        caption: "Single slide example with lightbox enabled",
        lightbox: true
      }
    ]
  end

  def chat_images_incoming_slides
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1497366412874-3415097a27e7?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1497366412874-3415097a27e7?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1497366216548-37526070297c?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=320&h=240&fit=crop",
        lightbox: true
      }
    ]
  end

  def chat_images_outgoing_slides
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=320&h=240&fit=crop",
        lightbox: true
      },
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1520607162513-77705c0f0d4a?w=320&h=240&fit=crop",
        lightbox: true
      }
    ]
  end

  def chat_images_single_incoming_slides
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=320&h=240&fit=crop",
        lightbox: true
      }
    ]
  end

  def chat_images_single_outgoing_slides
    [
      {
        type: :image,
        src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=1600&h=1200&fit=crop",
        thumb_src: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=320&h=240&fit=crop",
        lightbox: true
      }
    ]
  end

  def load_demo_theme_tokens
    return unless request.get?
    return unless request.format.html?

    mapping = DEMO_THEME_TOKEN_MAPPINGS.find { |entry| action_name.match?(entry.fetch(:action)) }
    return unless mapping

    rows = extract_theme_tokens.select do |token|
      mapping.fetch(:patterns).any? { |pattern| token.fetch(:variable).match?(pattern) }
    end
    return if rows.empty?

    @demo_theme_token_title = mapping.fetch(:title)
    @demo_theme_token_rows = rows
  end

  def extract_theme_tokens
    css = cached_theme_variables_css
    block = css[/@theme\s*\{(?<body>.*?)^\}/m, :body]
    return [] if block.blank?

    block.lines.filter_map do |line|
      stripped = line.strip
      next if stripped.empty? || stripped.start_with?("/*")

      match = stripped.match(/\A(--[a-z0-9-]+)\s*:\s*(.+);\z/)
      next unless match

      {
        variable: match[1],
        default_value: match[2]
      }
    end
  end

  def cached_theme_variables_css
    path = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css")
    mtime = File.mtime(path).to_i

    cache = self.class.instance_variable_get(:@theme_variables_css_cache)
    if cache&.fetch(:mtime, nil) == mtime
      return cache.fetch(:css)
    end

    css = File.read(path)
    self.class.instance_variable_set(:@theme_variables_css_cache, {mtime: mtime, css: css})
    css
  end
end
