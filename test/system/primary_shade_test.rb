# frozen_string_literal: true

require "test_helper"

class PrimaryShadeTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "wrapper color-primary changes the computed hover and pressed" do
    visit demo_buttons_path

    shades = brand_shades
    blue = shades.fetch("blue")
    green = shades.fetch("green")

    assert_color_apart blue.fetch("rest"), blue.fetch("hover")
    assert_color_apart blue.fetch("hover"), blue.fetch("pressed")
    assert_color_apart blue.fetch("hover"), green.fetch("hover")
    assert_color_apart blue.fetch("pressed"), green.fetch("pressed")
    assert_operator luminance(blue.fetch("hover")), :<, luminance(blue.fetch("rest"))
    assert_operator luminance(blue.fetch("pressed")), :<, luminance(blue.fetch("hover"))
  end

  test "explicit hover and pressed pins win over the mix" do
    visit demo_buttons_path
    pin_blue("--button-primary-hover-background-color" => "rgb(1, 2, 3)", "--button-primary-active-background-color" => "rgb(4, 5, 6)")

    blue = brand_shades.fetch("blue")

    assert_equal "rgb(1, 2, 3)", blue.dig("hover", "raw")
    assert_equal "rgb(4, 5, 6)", blue.dig("pressed", "raw")
    refute_equal blue.dig("rest", "raw"), blue.dig("hover", "raw")
  end

  test "dark theme mixes primary hover and pressed toward white" do
    visit demo_buttons_path
    light = brand_shades.fetch("blue")
    set_theme("dark")
    dark = brand_shades.fetch("blue")

    assert_operator luminance(dark.fetch("hover")), :>, luminance(dark.fetch("rest"))
    assert_operator luminance(dark.fetch("pressed")), :>, luminance(dark.fetch("hover"))
    assert_operator luminance(dark.fetch("hover")), :>, luminance(light.fetch("hover"))
  end

  test "ocean keeps its hover pin" do
    visit demo_buttons_path
    set_theme("ocean")
    shades = brand_shades

    hovers = %w[blue green yellow].map { |name| shades.dig(name, "hover", "raw") }

    assert_equal [hovers.first], hovers.uniq
    assert_includes hovers.first, "0.42"
    assert_includes hovers.first, "220"
    assert_color_apart shades.dig("blue", "rest"), shades.dig("blue", "hover")
    assert_in_delta 29, shades.dig("blue", "rest", "r"), 2
    assert_in_delta 78, shades.dig("blue", "rest", "g"), 2
    assert_in_delta 216, shades.dig("blue", "rest", "b"), 2
  end

  private

  def set_theme(name)
    page.execute_script(<<~JS, name)
      document.documentElement.setAttribute("data-theme", arguments[0])
    JS
  end

  def pin_blue(pins)
    page.execute_script(<<~JS, pins)
      const wrapper = document.querySelector("section div[style*='--color-primary']")
      Object.entries(arguments[0]).forEach(([token, color]) => wrapper.style.setProperty(token, color))
    JS
  end

  def brand_shades
    page.evaluate_script(<<~JS)
      (() => {
        let sheet = document.getElementById("fp-test-no-motion")
        if (!sheet) {
          sheet = document.createElement("style")
          sheet.id = "fp-test-no-motion"
          sheet.textContent = "*, *::before, *::after { transition: none !important; animation: none !important; }"
          document.head.appendChild(sheet)
        }
        const section = [...document.querySelectorAll("section")].find((node) => node.innerText.includes("Brand colour"))
        const wrappers = [...section.querySelectorAll("div[style*='--color-primary']")]
        const paint = (button) => {
          const raw = getComputedStyle(button).backgroundColor
          const canvas = document.createElement("canvas")
          canvas.width = canvas.height = 1
          const context = canvas.getContext("2d", { willReadFrequently: true })
          context.fillStyle = raw
          context.fillRect(0, 0, 1, 1)
          const [r, g, b, a] = context.getImageData(0, 0, 1, 1).data
          return { r, g, b, a, raw }
        }
        const read = (wrapper) => {
          const buttons = [...wrapper.querySelectorAll(".fp-button")]
          return { rest: paint(buttons[0]), hover: paint(buttons[1]), pressed: paint(buttons[2]) }
        }
        return { blue: read(wrappers[0]), green: read(wrappers[1]), yellow: read(wrappers[2]) }
      })()
    JS
  end

  def luminance(sample)
    (0.2126 * sample.fetch("r")) + (0.7152 * sample.fetch("g")) + (0.0722 * sample.fetch("b"))
  end

  def assert_color_apart(left, right)
    refute_equal [left.fetch("r"), left.fetch("g"), left.fetch("b")], [right.fetch("r"), right.fetch("g"), right.fetch("b")]
  end
end
