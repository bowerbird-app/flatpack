# frozen_string_literal: true

require "test_helper"

class ImportmapPreloadTest < ActionDispatch::IntegrationTest
  HEAVY_MODULE = /apexcharts|lowlight|@tiptap/

  test "engine importmap does not preload any pin" do
    map = Importmap::Map.new
    map.draw(FlatPack::Engine.root.join("config/importmap.rb"))

    %w[apexcharts lowlight @tiptap/core @tiptap/starter-kit].each do |name|
      assert map.packages.key?(name), "#{name} stays pinned"
      assert_equal false, map.packages.fetch(name).preload
    end

    map.packages.each do |name, package|
      assert_equal false, package.preload, name
    end

    map.directories.each do |dir, mapping|
      assert_equal false, mapping.preload, dir.to_s
    end
  end

  test "plain page does not modulepreload chart or editor libraries" do
    get "/"

    assert_response :success

    heavy = modulepreload_hrefs(response.body).grep(HEAVY_MODULE)
    assert_empty heavy

    assert_includes response.body, '"apexcharts"'
    assert_includes response.body, '"lowlight"'
    assert_includes response.body, '"@tiptap/core"'
  end

  test "chart page still mounts the chart controller" do
    get "/demo/charts"

    assert_response :success
    assert_includes response.body, "flat-pack--chart"
    source = File.read(FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/chart_controller.js"))
    assert_includes source, 'import("apexcharts")'
  end

  test "editor page still mounts the rich text editor" do
    get "/demo/forms/text_area"

    assert_response :success
    assert_includes response.body, "flat-pack--tiptap"
    registry = File.read(FlatPack::Engine.root.join("app/javascript/flat_pack/tiptap/extension_registry.js"))
    assert_includes registry, 'tryImport("lowlight")'
    assert_includes registry, 'import("@tiptap/starter-kit")'
  end

  private

  def modulepreload_hrefs(html)
    Nokogiri::HTML(html).css('link[rel="modulepreload"]').map { |node| node["href"].to_s }
  end
end
