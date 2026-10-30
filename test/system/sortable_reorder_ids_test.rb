# frozen_string_literal: true

require "test_helper"

class SortableReorderIdsTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 800] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  TABLE_UUIDS = [
    "6f1e1a4a-1c2b-4d3e-8f90-111111111111",
    "6f1e1a4a-1c2b-4d3e-8f90-222222222222"
  ].freeze

  GRID_UUIDS = [
    "6f1e1a4a-1c2b-4d3e-8f90-333333333333",
    "6f1e1a4a-1c2b-4d3e-8f90-444444444444"
  ].freeze

  test "dragging a table sends string uuid ids to the server" do
    visit "/demo/tables/draggable"
    ids = drag_uuid_reorder("tr[data-flat-pack--table-sortable-target='row']", TABLE_UUIDS)

    assert_equal TABLE_UUIDS.sort, (ids & TABLE_UUIDS).sort
    ids.each { |id| assert_kind_of String, id }
  end

  test "dragging a grid sends string uuid ids to the server" do
    visit "/demo/grid/movable_cards"
    ids = drag_uuid_reorder("[data-flat-pack--grid-sortable-target='item']", GRID_UUIDS)

    assert_equal GRID_UUIDS.sort, (ids & GRID_UUIDS).sort
    ids.each { |id| assert_kind_of String, id }
  end

  private

  def drag_uuid_reorder(selector, uuids)
    assert_selector selector, minimum: 2
    page.execute_script(<<~JS, uuids[0], uuids[1], selector)
      const nodes = document.querySelectorAll(arguments[2])
      nodes[0].dataset.id = arguments[0]
      nodes[1].dataset.id = arguments[1]
    JS

    captured = capture_reorder_params do
      rows = all(selector, minimum: 2)
      rows[0].drag_to(rows[1])
    end

    item_ids(captured)
  end

  def capture_reorder_params
    queue = Thread::Queue.new
    subscriber = ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*args|
      payload = args.last
      queue << payload[:params] if payload[:action] == "tables_reorder"
    end

    yield

    queue.pop(timeout: 5) || flunk("reorder request was not received")
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  def item_ids(params)
    items = params.dig("reorder", "items") || params.dig(:reorder, :items) || []
    items = items.values if items.respond_to?(:values) && !items.is_a?(Array)
    Array(items).map { |item| item["id"] || item[:id] }
  end
end
