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
  end
end
