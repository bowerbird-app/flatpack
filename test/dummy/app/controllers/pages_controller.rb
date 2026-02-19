# frozen_string_literal: true

require "ostruct"

class PagesController < ApplicationController
  def demo
    @component_index = build_component_index
  end

  def buttons
  end

  def tables
    ensure_demo_table_rows!

    @users = Array.new(20) do |i|
      OpenStruct.new(
        id: i + 1,
        name: "User #{i + 1}",
        email: "user#{i + 1}@example.com",
        status: %w[active inactive pending].sample,
        created_at: rand(30).days.ago
      )
    end

    # Handle sorting for sortable table
    @sorted_users = sort_users(@users.dup, params[:sort], params[:direction])
    @demo_table_rows = DemoTableRow.where(list_key: DemoTableRow::DEFAULT_LIST_KEY).ordered
    @demo_table_version = demo_table_version
  end

  def tables_reorder
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

  def toasts
  end

  def page_header
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

  def pagination
    require "pagy"
    @pagy, @records = pagy_array(Array.new(100) { |i|
      OpenStruct.new(id: i + 1, name: "Item #{i + 1}")
    }, items: 10)
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

  private

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

  def build_component_entry(file_path, component_root)
    relative_file_path = Pathname.new(file_path).relative_path_from(component_root).to_s
    component_path = relative_file_path.delete_suffix(".rb")
    class_name = component_class_name(component_path)
    component_class = class_name.safe_constantize
    return unless component_class

    {
      name: class_name.delete_prefix("FlatPack::"),
      description: component_description(component_path),
      variables: initializer_variables(component_class),
      methods: public_component_methods(component_class)
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
    return if DemoTableRow.where(list_key: DemoTableRow::DEFAULT_LIST_KEY).exists?

    rows = [
      {name: "Backlog grooming", status: "pending", priority: "low"},
      {name: "Design QA", status: "active", priority: "high"},
      {name: "API integration", status: "active", priority: "medium"},
      {name: "Release checklist", status: "inactive", priority: "medium"},
      {name: "Retrospective prep", status: "pending", priority: "low"}
    ]

    rows.each_with_index do |row, index|
      DemoTableRow.create!(
        list_key: DemoTableRow::DEFAULT_LIST_KEY,
        name: row[:name],
        status: row[:status],
        priority: row[:priority],
        position: index + 1
      )
    end
  end

  def demo_table_version(scope = {list_key: DemoTableRow::DEFAULT_LIST_KEY})
    DemoTableRow.where(scope).maximum(:updated_at)&.to_f&.to_s || "0"
  end

  def searchable_items
    [
      {title: "Overview", description: "FlatPack component library home", url: demo_path},
      {title: "Buttons", description: "Button variants and dropdown examples", url: demo_buttons_path},
      {title: "Forms", description: "Form submit patterns with HTTP methods", url: demo_forms_path},
      {title: "Inputs", description: "Input components with validation and states", url: demo_inputs_path},
      {title: "Tables", description: "Data tables with sorting support", url: demo_tables_path},
      {title: "Cards", description: "Composed card layouts", url: demo_cards_path},
      {title: "Alerts", description: "Status and feedback messages", url: demo_alerts_path},
      {title: "Badges", description: "Label and status indicators", url: demo_badges_path},
      {title: "Breadcrumbs", description: "Hierarchical navigation trails", url: demo_breadcrumbs_path},
      {title: "Top Nav", description: "Header layout with left, center, and right slots", url: demo_navbar_path},
      {title: "Search", description: "Reusable search component with live results", url: demo_search_path},
      {title: "Sidebar", description: "Sidebar and layout examples", url: demo_sidebar_layout_path},
      {title: "Modals", description: "Dialog overlays with focus trap", url: demo_modals_path},
      {title: "Popovers", description: "Click-triggered floating content", url: demo_popovers_path},
      {title: "Tooltips", description: "Hover/focus tooltips", url: demo_tooltips_path},
      {title: "Tabs", description: "Tabbed content with keyboard navigation", url: demo_tabs_path},
      {title: "Toasts", description: "Auto-dismissing notifications", url: demo_toasts_path},
      {title: "Page Header", description: "Page title with optional subtitle", url: demo_page_header_path},
      {title: "Empty State", description: "User-friendly empty states", url: demo_empty_state_path},
      {title: "Grid", description: "Responsive grid layouts", url: demo_grid_path},
      {title: "Pagination", description: "Page navigation with Pagy", url: demo_pagination_path},
      {title: "Charts", description: "Data visualization with ApexCharts", url: demo_charts_path},
      {title: "Code Blocks", description: "Reusable snippets for demo pages", url: demo_code_blocks_path}
    ]
  end
end
