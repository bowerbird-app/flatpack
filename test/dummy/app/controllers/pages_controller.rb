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
      {title: "Sidebar", description: "Sidebar and layout examples", url: demo_sidebar_layout_path}
    ]
  end
end
