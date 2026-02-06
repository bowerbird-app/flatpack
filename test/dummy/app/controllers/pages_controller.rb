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
    @users = 20.times.map do |i|
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

  private

  def sort_users(users, sort_column, direction)
    return users unless sort_column.present?

    # Validate sort column
    valid_columns = %w[id name email status created_at]
    return users unless valid_columns.include?(sort_column)

    # Validate direction
    direction = (direction == "desc") ? "desc" : "asc"

    # Sort users
    sorted = users.sort_by do |user|
      value = user.public_send(sort_column)
      # Handle nil values
      value.nil? ? "" : value
    end

    (direction == "desc") ? sorted.reverse : sorted
  end

  def inputs
  end

  def badges
  end

  def alerts
  end

  def navbar
  end
end
