# frozen_string_literal: true

require "test_helper"

class BackdropContentTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "rounded float title is light and the card heading stays dark" do
    visit "/demo/page_layout?variant=float"

    title = paint("#page-layout-float-title h1")
    card = paint("#page-layout-float h1")

    assert_operator luminance(title), :>, 200
    assert_operator luminance(card), :<, 80
    assert_in_delta 51, luminance(card), 12
    refute_equal rgb(title), rgb(card)
  end

  test "light float title and card heading are both dark and close" do
    visit "/demo/page_layout?variant=float&theme=light"

    title = paint("#page-layout-float-title h1")
    card = paint("#page-layout-float h1")

    assert_operator luminance(title), :<, 80
    assert_operator luminance(card), :<, 80
    assert_in_delta luminance(title), luminance(card), 12
    rgb(title).zip(rgb(card)).each do |left, right|
      assert_in_delta left, right, 8
    end
  end

  test "dark float title is light" do
    visit "/demo/page_layout?variant=float&theme=dark"

    title = paint("#page-layout-float-title h1")

    assert_operator luminance(title), :>, 200
  end

  test "adding the class to main does not recolour the card" do
    visit "/demo/page_layout?variant=float"

    before = paint("#page-layout-float h1")
    page.execute_script("document.querySelector('main').classList.add('fp-on-backdrop')")
    after = paint("#page-layout-float h1")
    title = paint("#page-layout-float-title h1")

    assert_equal before.fetch("raw"), after.fetch("raw")
    assert_operator luminance(title), :>, 200
  end

  test "the class does nothing on a page with no photo" do
    visit "/demo/page_layout"

    before = paint("#page-layout-plain h1")
    page.execute_script("document.querySelector('#page-layout-plain h1').classList.add('fp-on-backdrop')")
    after = paint("#page-layout-plain h1")

    assert_equal before.fetch("raw"), after.fetch("raw")
  end

  private

  def paint(selector)
    page.evaluate_script(<<~JS)
      (() => {
        const node = document.querySelector(#{selector.to_json})
        const raw = getComputedStyle(node).color
        const canvas = document.createElement("canvas")
        canvas.width = canvas.height = 1
        const context = canvas.getContext("2d", { willReadFrequently: true })
        context.fillStyle = raw
        context.fillRect(0, 0, 1, 1)
        const [r, g, b, a] = context.getImageData(0, 0, 1, 1).data
        return { r, g, b, a, raw }
      })()
    JS
  end

  def luminance(sample)
    (0.2126 * sample.fetch("r")) + (0.7152 * sample.fetch("g")) + (0.0722 * sample.fetch("b"))
  end

  def rgb(sample)
    [sample.fetch("r"), sample.fetch("g"), sample.fetch("b")]
  end
end
