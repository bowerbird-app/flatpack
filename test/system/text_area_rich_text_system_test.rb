# frozen_string_literal: true

require "application_system_test_case"

class TextAreaRichTextSystemTest < ApplicationSystemTestCase
  test "typing syncs rich text content into the hidden field" do
    visit "/demo/forms/text_area"

    assert_selector "#rich-text-minimal.ProseMirror", wait: 10

    find("#rich-text-minimal").click.send_keys(" Additional copy")

    hidden_input = find("#rich-text-minimal_input", visible: false)
    assert_includes hidden_input.value, "Additional copy"
  end

  test "toolbar actions can insert table content" do
    visit "/demo/forms/text_area"

    assert_selector "#rich-text-full.ProseMirror", wait: 10

    wrapper = find(:xpath, "//*[@id='rich-text-full']/ancestor::div[contains(@class, 'flat-pack-input-wrapper')][1]")

    within(wrapper) do
      click_button "Table"
    end

    hidden_input = find("#rich-text-full_input", visible: false)
    assert_includes hidden_input.value, "\"table\""
  end

  test "bubble menu appears when text is selected" do
    visit "/demo/forms/text_area"

    assert_selector "#rich-text-bubble.ProseMirror", wait: 10

    page.execute_script(<<~JS)
      const editor = document.getElementById("rich-text-bubble")
      const textNode = editor.firstChild && editor.firstChild.firstChild
      if (textNode) {
        const range = document.createRange()
        range.setStart(textNode, 0)
        range.setEnd(textNode, textNode.textContent.length)
        const selection = window.getSelection()
        selection.removeAllRanges()
        selection.addRange(range)
        editor.dispatchEvent(new MouseEvent("mouseup", { bubbles: true }))
      }
    JS

    assert_selector "[data-flat-pack--tiptap-target='bubbleMenu']:not(.hidden)", wait: 10
  end
end
