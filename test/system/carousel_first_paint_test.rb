# frozen_string_literal: true

require "test_helper"

class CarouselFirstPaintTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  WIDTHS = {
    "mobile" => 375,
    "tablet" => 800,
    "desktop" => 1280
  }.freeze

  RATIOS = {
    "carousel-one-up" => {"mobile" => 1.0, "tablet" => 1.0, "desktop" => 1.0},
    "carousel-preview" => {"mobile" => 1.0 / 1.25, "tablet" => 1.0 / 2.25, "desktop" => 1.0 / 4.25},
    "carousel-offset" => {"mobile" => 1.0 / 1.25, "tablet" => 1.0 / 2.25, "desktop" => 1.0 / 4.25}
  }.freeze

  test "slide widths and height match before and after the controller connects" do
    visit "/demo/carousel/first-paint"
    freeze_motion
    install_layout_helpers

    WIDTHS.each do |name, width|
      page.current_window.resize_to(width, 900)
      settle

      RATIOS.each_key do |id|
        live = snapshot(id)
        paint = first_paint(id)

        assert_in_delta live.fetch("height"), paint.fetch("height"), 1, "#{id} height at #{name}"
        assert_equal live.fetch("widths").size, paint.fetch("widths").size

        live.fetch("widths").zip(paint.fetch("widths")).each_with_index do |(left, right), index|
          assert_in_delta left, right, 1, "#{id} slide #{index} width at #{name}"
        end

        live.fetch("offsets").zip(paint.fetch("offsets")).each_with_index do |(left, right), index|
          assert_in_delta left, right, 1, "#{id} slide #{index} offset at #{name}"
        end

        ratio = live.fetch("widths").first / live.fetch("frameWidth")
        assert_in_delta RATIOS.fetch(id).fetch(name), ratio, 0.02, "#{id} ratio at #{name} (inner #{live.fetch("innerWidth")})"
      end

      offset = snapshot("carousel-offset")
      assert_in_delta 0, offset.fetch("offsets")[2], 2, "third card starts in view at #{name}"
    end

    page.current_window.resize_to(1280, 900)
    settle
    counter = find("#carousel-one-up [data-flat-pack--carousel-target='counter']")
    assert_equal "1 / 6", counter.text
    find("#carousel-one-up button[data-action='click->flat-pack--carousel#next']").click
    settle
    assert_equal "2 / 6", counter.text
    moved = snapshot("carousel-one-up")
    assert_operator moved.fetch("offsets").first, :<, -20
  end

  test "the demo card row does not grow when the controller connects" do
    page.current_window.resize_to(390, 900)
    page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
      window.__cls = 0
      window.__carouselSamples = []
      new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (!entry.hadRecentInput) window.__cls += entry.value
        }
      }).observe({ type: "layout-shift", buffered: true })
      const sample = () => {
        const viewport = document.querySelector("[aria-label='Episode row']")
        if (!viewport) return
        window.__carouselSamples.push(Math.round(viewport.getBoundingClientRect().height))
      }
      const timer = setInterval(sample, 50)
      addEventListener("load", () => setTimeout(() => clearInterval(timer), 600))
    JS

    visit "/demo/carousel"
    freeze_motion
    install_layout_helpers
    settle

    live = snapshot_root("episode-row")
    paint = first_paint_root("episode-row")
    old_paint = hidden_slide_height("episode-row")
    shift = page.evaluate_script("({cls: window.__cls || 0, samples: window.__carouselSamples || []})")

    assert_in_delta live.fetch("height"), paint.fetch("height"), 1
    path = File.expand_path("../../tmp/carousel-demo-heights.json", __dir__)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, JSON.generate({
      "live" => live.fetch("height"),
      "css" => paint.fetch("height"),
      "hidden_slides" => old_paint,
      "widths" => live.fetch("widths"),
      "cls" => shift["cls"],
      "samples" => shift["samples"]
    }))
  end

  private

  def freeze_motion
    page.execute_script(<<~JS)
      const sheet = document.createElement("style")
      sheet.textContent = "*, *::before, *::after { transition: none !important; animation: none !important; }"
      document.head.appendChild(sheet)
    JS
  end

  def settle
    page.evaluate_async_script(<<~JS)
      const done = arguments[arguments.length - 1]
      requestAnimationFrame(() => requestAnimationFrame(() => setTimeout(done, 50)))
    JS
  end

  def install_layout_helpers
    page.execute_script(<<~JS)
      window.__carouselRoot = function (key) {
        if (key === "episode-row") {
          const viewport = document.querySelector("[aria-label='Episode row']")
          return viewport && viewport.closest("[data-controller='flat-pack--carousel']")
        }
        return document.getElementById(key)
      }

      window.__carouselSnapshot = function (root) {
        const viewport = root.querySelector("[data-flat-pack--carousel-target='viewport']")
        const frame = root.querySelector("[data-flat-pack--carousel-target='frame']")
        const slides = Array.from(root.querySelectorAll("[data-flat-pack--carousel-target='slide']"))
        const box = viewport.getBoundingClientRect()
        return {
          height: box.height,
          frameWidth: frame.getBoundingClientRect().width,
          widths: slides.map((slide) => slide.getBoundingClientRect().width),
          offsets: slides.map((slide) => slide.getBoundingClientRect().left - box.left),
          innerWidth: window.innerWidth
        }
      }

      window.__carouselFirstPaint = function (root) {
        const width = root.getBoundingClientRect().width
        const clone = root.cloneNode(true)
        clone.removeAttribute("id")
        clone.removeAttribute("data-controller")
        clone.querySelectorAll("[data-flat-pack--carousel-target='slide']").forEach((slide) => {
          slide.style.flexBasis = ""
          slide.style.maxWidth = ""
          slide.hidden = false
        })
        const frame = clone.querySelector("[data-flat-pack--carousel-target='frame']")
        if (frame) frame.style.transform = ""
        clone.style.position = "absolute"
        clone.style.left = "0"
        clone.style.top = "0"
        clone.style.width = width + "px"
        clone.style.visibility = "hidden"
        clone.style.pointerEvents = "none"
        document.body.appendChild(clone)
        const shot = window.__carouselSnapshot(clone)
        clone.remove()
        return shot
      }
    JS
  end

  def snapshot(id)
    page.evaluate_script("window.__carouselSnapshot(window.__carouselRoot(arguments[0]))", id)
  end

  def snapshot_root(key)
    snapshot(key)
  end

  def first_paint(id)
    page.evaluate_script("window.__carouselFirstPaint(window.__carouselRoot(arguments[0]))", id)
  end

  def first_paint_root(key)
    first_paint(key)
  end

  def hidden_slide_height(key)
    page.evaluate_script(<<~JS, key)
      (function (key) {
        const root = window.__carouselRoot(key)
        const viewport = root.querySelector("[data-flat-pack--carousel-target='viewport']")
        const frame = root.querySelector("[data-flat-pack--carousel-target='frame']")
        const slides = Array.from(root.querySelectorAll("[data-flat-pack--carousel-target='slide']"))
        const saved = slides.map((slide) => ({
          hidden: slide.hidden,
          flexBasis: slide.style.flexBasis,
          maxWidth: slide.style.maxWidth
        }))
        const transform = frame.style.transform
        slides.forEach((slide, index) => {
          slide.hidden = index !== 0
          slide.style.flexBasis = ""
          slide.style.maxWidth = ""
        })
        frame.style.transform = "none"
        const height = viewport.getBoundingClientRect().height
        slides.forEach((slide, index) => {
          slide.hidden = saved[index].hidden
          slide.style.flexBasis = saved[index].flexBasis
          slide.style.maxWidth = saved[index].maxWidth
        })
        frame.style.transform = transform
        return height
      })(arguments[0])
    JS
  end
end
