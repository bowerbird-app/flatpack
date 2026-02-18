# frozen_string_literal: true

require "ostruct"

class PagesController < ApplicationController
  def demo
    @users = [
      OpenStruct.new(id: 1, name: "Alice Johnson", email: "alice@example.com", status: "active"),
      OpenStruct.new(id: 2, name: "Bob Smith", email: "bob@example.com", status: "inactive"),
      OpenStruct.new(id: 3, name: "Charlie Brown", email: "charlie@example.com", status: "active")
    ]
  end

  def buttons
  end

  def tables
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
  end

  def inputs
  end

  def badges
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

  private

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
      {title: "Page Header", description: "Page title with actions and breadcrumbs", url: demo_page_header_path},
      {title: "Empty State", description: "User-friendly empty states", url: demo_empty_state_path},
      {title: "Grid", description: "Responsive grid layouts", url: demo_grid_path},
      {title: "Pagination", description: "Page navigation with Pagy", url: demo_pagination_path},
      {title: "Charts", description: "Data visualization with ApexCharts", url: demo_charts_path}
    ]
  end
end
