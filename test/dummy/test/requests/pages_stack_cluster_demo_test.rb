# frozen_string_literal: true

require "test_helper"

class PagesStackClusterDemoTest < ActionDispatch::IntegrationTest
  test "stack demo renders a vertical flex column with the grid gap scale" do
    get demo_stack_path

    assert_response :success
    assert_includes response.body, "FlatPack::Stack::Component"
    assert_includes response.body, "flex flex-col"
    assert_includes response.body, "gap-4"
    assert_includes response.body, "items-stretch"
    assert_includes response.body, "items-start"
    assert_includes response.body, "gap: :sm"
  end

  test "cluster demo renders a wrapping flex row with justify" do
    get demo_cluster_path

    assert_response :success
    assert_includes response.body, "FlatPack::Cluster::Component"
    assert_includes response.body, "flex flex-wrap"
    assert_includes response.body, "justify-between"
    assert_includes response.body, "items-center"
    assert_includes response.body, "Northlight"
  end

  test "stack demo sidebar includes cluster" do
    get demo_stack_path

    assert_response :success
    assert_includes response.body, demo_cluster_path
    assert_includes response.body, "Cluster"
  end
end
