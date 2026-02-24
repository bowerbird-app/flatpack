# frozen_string_literal: true

require "test_helper"

class PagesGridDemoTest < ActionDispatch::IntegrationTest
  test "movable cards page renders sortable grid controller" do
    get demo_grid_movable_cards_path

    assert_response :success
    assert_includes response.body, "Movable Cards Grid"
    assert_includes response.body, "data-controller=\"flat-pack--grid-sortable\""
    assert_includes response.body, "data-flat-pack--grid-sortable-target=\"item\""
  end

  test "grid page sidebar includes movable cards link" do
    get demo_grid_path

    assert_response :success
    assert_includes response.body, demo_grid_movable_cards_path
    assert_includes response.body, "Movable Cards"
  end
end
