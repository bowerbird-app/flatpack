# frozen_string_literal: true

require "test_helper"

class FileInputShowFileListTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 900] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "a dropzone with show_file_list false still dispatches the change event" do
    visit "/demo/forms/file_input"
    stem = Rails.root.join("tmp/mix-stem.txt")
    FileUtils.mkdir_p(stem.dirname)
    File.write(stem, "mix")

    page.execute_script(<<~JS)
      window.fileInputEvents = []
      document.addEventListener("flat-pack:file-input:change", (event) => {
        const files = event.detail && event.detail.files ? event.detail.files : []
        window.fileInputEvents.push({
          keys: Object.keys(event.detail || {}),
          names: Array.from(files).map((file) => file.name),
          files: Array.from(files).every((file) => file instanceof File)
        })
      })
    JS

    within("#file-input-host-list") do
      refute_selector "[data-flat-pack--file-input-target='fileList']", visible: :all
      attach_file("stems", stem.to_s, make_visible: true)
      refute_selector "[data-flat-pack--file-input-target='fileList']", visible: :all
    end

    assert_text "mix-stem.txt"

    payload = page.evaluate_script("window.fileInputEvents")
    assert_equal 1, payload.length
    assert_equal ["files"], payload.first["keys"]
    assert_equal ["mix-stem.txt"], payload.first["names"]
    assert_equal true, payload.first["files"]
  ensure
    FileUtils.rm_f(Rails.root.join("tmp/mix-stem.txt"))
  end
end
