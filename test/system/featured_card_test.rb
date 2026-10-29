# frozen_string_literal: true

require "test_helper"

class FeaturedCardTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [375, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "share and heart glyphs use the button text colour on a phone" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured button[aria-label='Share'] svg path"
    assert_selector ".fp-card--featured button[aria-label='Add to list'] svg path"

    share = glyph("Share")
    heart = glyph("Add to list")

    assert_operator luminance(share), :<, 80
    assert_operator luminance(heart), :<, 80
    assert_in_delta luminance(share), luminance(heart), 1
    assert_equal share.fetch("button"), share.fetch("stroke")
  end

  test "a light text class on an ancestor does not bleach the glyph" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured button[aria-label='Share'] svg path"

    before = glyph("Share")
    page.execute_script(<<~JS)
      document.querySelector(".fp-card--featured").classList.add("text-white")
      document.querySelector(".fp-card--featured .fp-overlay").classList.add("text-white")
    JS
    after = glyph("Share")

    assert_equal before.fetch("stroke"), after.fetch("stroke")
    assert_operator luminance(after), :<, 80
  end

  test "a text class on the icon wins over the button colour" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured button[aria-label='Share'] svg path"

    page.execute_script(<<~JS)
      document.querySelector(".fp-card--featured button[aria-label='Share'] svg").classList.add("text-white")
    JS
    painted = glyph("Share")

    assert_operator luminance(painted), :>, 200
  end

  test "a card title variable changes the computed size" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured .fp-card__title", text: "Spring launch"

    sample = page.evaluate_script(<<~JS)
      (() => {
        const card = document.querySelector(".fp-card--featured")
        const title = card.querySelector(".fp-card__title")
        const probe = document.createElement("div")
        probe.style.fontSize = "var(--text-4xl)"
        card.appendChild(probe)
        const before = getComputedStyle(title).fontSize
        const featured = getComputedStyle(probe).fontSize
        probe.remove()
        card.style.setProperty("--card-title-size", "13px")
        const after = getComputedStyle(title).fontSize
        return { before, featured, after }
      })()
    JS

    assert_equal sample.fetch("featured"), sample.fetch("before")
    assert_equal "13px", sample.fetch("after")
    refute_equal sample.fetch("before"), sample.fetch("after")
  end

  test "media outside a featured card uses h-auto instead of the attribute height" do
    visit "/demo/cards"
    image = find("img[alt='Packaging']", match: :first)
    assert_includes image[:class], "h-auto"

    sample = page.evaluate_script(<<~JS)
      (() => {
        const image = document.querySelector("img[alt='Packaging']")
        return {
          used: image.getBoundingClientRect().height,
          attribute: Number(image.getAttribute("height"))
        }
      })()
    JS

    assert_operator sample.fetch("used"), :<, sample.fetch("attribute")
  end

  test "featured cover uses the image height token and a host utility wins" do
    visit "/demo/cards"

    sample = page.evaluate_script(<<~JS)
      (() => {
        const image = document.querySelector(".fp-card--featured .fp-media__image")
        const card = image.closest(".fp-card--featured")
        const overlay = image.closest(".fp-overlay")
        image.style.aspectRatio = "16 / 9"
        const cover = image.getBoundingClientRect()
        const slot = overlay.getBoundingClientRect()
        image.classList.add("h-px")
        const host = image.getBoundingClientRect().height
        image.classList.remove("h-px")
        card.style.setProperty("--card-media-image-height", "13px")
        const token = image.getBoundingClientRect().height
        return {
          classes: image.className,
          cover: cover.height,
          width: cover.width,
          slot: slot.height,
          host,
          token
        }
      })()
    JS

    refute_includes sample.fetch("classes"), "h-auto"
    assert_in_delta sample.fetch("slot"), sample.fetch("cover"), 1
    assert_in_delta sample.fetch("width"), sample.fetch("cover"), 1
    assert_in_delta 1, sample.fetch("host"), 0.5
    assert_in_delta 13, sample.fetch("token"), 0.5
  end

  private

  def glyph(label)
    page.evaluate_script(<<~JS)
      (() => {
        const button = document.querySelector('.fp-card--featured button[aria-label=#{label.to_json}]')
        const path = button.querySelector("svg path")
        const stroke = getComputedStyle(path).stroke
        const buttonColor = getComputedStyle(button).color
        const canvas = document.createElement("canvas")
        canvas.width = canvas.height = 1
        const context = canvas.getContext("2d", { willReadFrequently: true })
        context.fillStyle = stroke
        context.fillRect(0, 0, 1, 1)
        const [r, g, b, a] = context.getImageData(0, 0, 1, 1).data
        return { r, g, b, a, stroke, button: buttonColor }
      })()
    JS
  end

  def luminance(sample)
    (0.2126 * sample.fetch("r")) + (0.7152 * sample.fetch("g")) + (0.0722 * sample.fetch("b"))
  end
end
