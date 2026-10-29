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

  test "a card title weight variable changes the computed weight" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured .fp-card__title", text: "Spring launch"

    sample = page.evaluate_script(<<~JS)
      (() => {
        const card = document.querySelector(".fp-card--featured")
        const title = card.querySelector(".fp-card__title")
        const before = getComputedStyle(title).fontWeight
        card.style.setProperty("--card-title-weight", "200")
        const after = getComputedStyle(title).fontWeight
        return { before, after, classes: title.className }
      })()
    JS

    refute_includes sample.fetch("classes").split, "font-semibold"
    assert_equal "600", sample.fetch("before")
    assert_equal "200", sample.fetch("after")
  end

  test "a wide featured cover stays square when the copy is tall" do
    [768, 1024].each do |width|
      page.current_window.resize_to(width, 900)
      visit "/demo/cards?copy=long"
      assert_selector ".fp-card--featured", text: "Lookbook spreads"

      sample = page.evaluate_script(<<~JS)
        (() => {
          const card = document.querySelector(".fp-card--featured")
          const cover = card.querySelector(".fp-card__cover")
          const box = cover.getBoundingClientRect()
          const cardBox = card.getBoundingClientRect()
          const sydney = [...card.querySelectorAll("p")].find((node) => node.textContent.trim() === "Sydney")
          const next = sydney.parentElement.nextElementSibling
          const gap = next.getBoundingClientRect().top - sydney.getBoundingClientRect().bottom
          const probe = document.createElement("div")
          probe.style.height = "var(--card-body-gap)"
          card.appendChild(probe)
          const expected = probe.getBoundingClientRect().height
          probe.remove()
          return { width: box.width, height: box.height, card: cardBox.height, gap, expected }
        })()
      JS

      assert_in_delta sample.fetch("width"), sample.fetch("height"), 1
      assert_operator sample.fetch("card"), :>, sample.fetch("height") + 40
      assert_in_delta sample.fetch("expected"), sample.fetch("gap"), 1
      assert_operator sample.fetch("gap"), :>, 8
    end
  end

  test "at 768 the featured card stacks" do
    page.current_window.resize_to(768, 900)
    visit "/demo/cards"
    assert_selector ".fp-card--featured", text: "Spring launch"

    sample = featured_columns

    assert sample.fetch("stacked"), "expected the cover above the copy"
    assert_operator sample.fetch("copyTop"), :>=, sample.fetch("mediaBottom") - 1
    assert_in_delta sample.fetch("copy"), sample.fetch("card"), 2
    assert_in_delta sample.fetch("cover"), sample.fetch("coverHeight"), 1
    assert_operator sample.fetch("headerTop"), :<, sample.fetch("mediaBottom")
  end

  test "a 500px wrapper stacks the featured card on a 1280 viewport" do
    page.current_window.resize_to(1280, 900)
    visit "/demo/cards?frame=500"
    assert_selector ".fp-card--featured", text: "Spring launch"

    sample = featured_columns

    assert sample.fetch("stacked"), "expected the cover above the copy"
    assert_in_delta 500, sample.fetch("card"), 2
    assert_in_delta sample.fetch("copy"), sample.fetch("card"), 2
    assert_operator sample.fetch("copyTop"), :>=, sample.fetch("mediaBottom") - 1
    assert_operator sample.fetch("pane"), :>, 700
  end

  test "a host width on a shrink-to-fit parent wins and the card does not collapse" do
    page.current_window.resize_to(1440, 900)
    visit "/demo/cards?frame=600"
    assert_selector ".fp-card--featured", text: "Spring launch"

    sample = featured_columns

    assert_in_delta 600, sample.fetch("card"), 2
    assert_in_delta 600, sample.fetch("host"), 2
    assert_operator sample.fetch("pane"), :>, 800
    assert sample.fetch("stacked"), "a 600px card stays stacked on a wide viewport"
    assert_operator sample.fetch("copyTop"), :>=, sample.fetch("mediaBottom") - 1
  end

  test "a host child with no width or aspect ratio keeps its height" do
    visit "/demo/cards"
    assert_selector ".fp-card--featured"

    sample = page.evaluate_script(<<~JS)
      (() => {
        const media = document.querySelector(".fp-card__featured-media")
        const style = document.createElement("style")
        style.textContent = ".host-unsized { width: auto; aspect-ratio: auto; height: auto; }"
        document.head.appendChild(style)
        const child = document.createElement("div")
        child.className = "host-unsized"
        child.textContent = "Host note"
        media.appendChild(child)
        const box = child.getBoundingClientRect()
        return { width: box.width, height: box.height, contain: getComputedStyle(child).contain }
      })()
    JS

    assert_operator sample.fetch("height"), :>, 8
    refute_includes sample.fetch("contain"), "size"
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

  def featured_columns
    page.evaluate_script(<<~JS)
      (() => {
        const card = document.querySelector(".fp-card--featured")
        const media = card.querySelector(".fp-card__featured-media")
        const copy = card.querySelector(".fp-card__featured-copy")
        const cover = card.querySelector(".fp-card__cover")
        const header = card.querySelector("[data-fp-card-part='header']")
        const root = parseFloat(getComputedStyle(document.documentElement).fontSize)
        const mediaBox = media.getBoundingClientRect()
        const copyBox = copy.getBoundingClientRect()
        const coverBox = cover.getBoundingClientRect()
        const cardBox = card.getBoundingClientRect()
        const pane = card.closest(".fp-pane-scroll") || document.body
        return {
          stacked: copyBox.top >= mediaBox.bottom - 2,
          copy: copyBox.width,
          copyTop: copyBox.top,
          cover: coverBox.width,
          coverHeight: coverBox.height,
          card: cardBox.width,
          host: card.parentElement.getBoundingClientRect().width,
          pane: pane.getBoundingClientRect().width,
          mediaBottom: mediaBox.bottom,
          headerTop: header.getBoundingClientRect().top,
          minCopy: 18 * root
        }
      })()
    JS
  end

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
