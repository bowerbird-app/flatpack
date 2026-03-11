# frozen_string_literal: true

require "application_system_test_case"
require "timeout"

class RichTextTextAreaTest < ApplicationSystemTestCase
  test "rich text textarea boots, syncs content, and reconnects safely" do
    visit "/demo/forms/text_area"

    assert_selector "#announcement_body_rich_text_editor", visible: :all, wait: 10
    wait_for_editor_instance!
    assert_equal true, page.evaluate_script("Boolean(window.CKEDITOR)")

    update_editor_html("<p>Updated <strong>announcement</strong> copy.</p>")
    wait_for_textarea_value!("<p>Updated <strong>announcement</strong> copy.</p>")

    page.execute_script(<<~JS)
      const wrapper = document.querySelector('[data-controller="flat-pack--rich-text-editor"]')
      const parent = wrapper.parentElement
      const replacement = wrapper.outerHTML
      wrapper.remove()
      parent.insertAdjacentHTML("beforeend", replacement)
    JS

    assert_selector "#announcement_body_rich_text_editor", visible: :all, wait: 10
    wait_for_editor_instance!
    update_editor_html("<p>Reconnected editor content.</p>")

    wait_for_textarea_value!("<p>Reconnected editor content.</p>")
    assert_equal 1, page.evaluate_script("Object.keys(window.CKEDITOR.instances).filter((key) => key === 'announcement_body_rich_text_editor').length")
  end

  private

  def update_editor_html(html)
    page.execute_script(<<~JS)
      const editor = window.CKEDITOR.instances.announcement_body_rich_text_editor
      editor.setData(#{html.to_json}, () => {
        editor.fire("change")
        editor.fire("blur")
      })
    JS
  end

  def wait_for_editor_instance!
    Timeout.timeout(10) do
      loop do
        ready = page.evaluate_script("Boolean(window.CKEDITOR && window.CKEDITOR.instances && window.CKEDITOR.instances.announcement_body_rich_text_editor)")
        break if ready

        sleep 0.1
      end
    end
  end

  def wait_for_textarea_value!(expected_html)
    Timeout.timeout(10) do
      loop do
        current_value = find("#announcement_body", visible: :all).value.to_s.strip
        break if current_value == expected_html

        sleep 0.1
      end
    end
  end
end
