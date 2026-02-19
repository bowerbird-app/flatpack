# frozen_string_literal: true

# Mock Pagy object for testing pagination components
# This provides a simple test double for the Pagy gem without requiring it as a dependency
class MockPagy
  attr_reader :page, :pages, :prev, :next, :series

  def initialize(page: 1, pages: 10, prev: nil, next_page: nil, series: [])
    @page = page
    @pages = pages
    @prev = prev
    @next = next_page
    @series = series
  end
end
