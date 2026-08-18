# frozen_string_literal: true

require "test_helper"

class DemoCatalogTest < ActiveSupport::TestCase
  test "searchable items include split demo pages" do
    titles = DemoCatalog.searchable_items.map { |item| item[:title] }

    assert_includes titles, "Accordion"
    assert_includes titles, "Links"
    assert_includes titles, "Pill Buttons"
    assert_includes titles, "Charts: Types"
    assert_includes titles, "Cards: Media"
    assert_includes titles, "Avatar Groups"
    assert_includes titles, "Chip Groups"
    assert_includes titles, "Date Range Input"
    assert_includes titles, "Page Nav"
    assert_includes titles, "Articles"
  end

  test "searchable item urls are absolute demo paths" do
    accordion = DemoCatalog.searchable_items.find { |item| item[:title] == "Accordion" }

    assert_equal "/demo/accordion", accordion[:url]
  end

  test "search ranks form titles ahead of formatting descriptions" do
    titles = DemoCatalog.search("form").map { |item| item[:title] }

    assert titles.any? { |title| title.downcase.include?("form") }
    refute_equal "Tables", titles.first
    assert titles.first.downcase.start_with?("form") || titles.first.downcase.include?("form")
    refute_includes titles.first(3), "Tables"
    refute_includes titles.first(3), "Tables: Basic"
    refute_includes titles, "Local Time"
  end

  test "sections drive sidebar groups for buttons and charts" do
    interactive = DemoCatalog.sections.find { |section| section[:title] == "Interactive" }
    buttons = interactive[:entries].find { |entry| entry[:type] == :group && entry[:title] == "Buttons" }

    assert_equal 6, buttons[:children].length

    data_display = DemoCatalog.sections.find { |section| section[:title] == "Data Display" }
    charts = data_display[:entries].find { |entry| entry[:type] == :group && entry[:title] == "Charts" }

    assert_includes charts[:children].map { |child| child[:title] }, "Composition"
  end
end
