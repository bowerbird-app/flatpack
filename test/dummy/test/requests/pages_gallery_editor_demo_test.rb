# frozen_string_literal: true

require "test_helper"

class PagesGalleryEditorDemoTest < ActionDispatch::IntegrationTest
  test "modals demo wires an opt-in navigable gallery editor" do
    get "/demo/modals"

    assert_response :success
    assert_includes response.body, "Image gallery editor"
    assert_includes response.body, 'id="gallery-editor"'
    assert_includes response.body, 'data-controller="flat-pack--modal flat-pack--navigable"'
    assert_includes response.body, "turbo-frame"
    assert_includes response.body, "gallery-editor-screen"
    assert_includes response.body, 'data-fp-nav="back"'
    assert_includes response.body, 'data-fp-nav="retry"'
    refute_includes response.body, 'data-fp-nav="push"'
    assert_select "#basic-modal[data-controller='flat-pack--modal']"
    assert_select "#basic-modal:not([data-flat-pack--modal-origin-value])"
    assert_select "#gallery-editor[data-controller='flat-pack--modal flat-pack--navigable']"
    assert_select "#gallery-editor:not([data-flat-pack--modal-origin-value])"
    assert_includes response.body, "Grow from the button"
    assert_select "#origin-top-left[data-flat-pack--modal-origin-value='trigger']"
    assert_select "#origin-centre[data-flat-pack--modal-origin-value='trigger']"
    assert_select "#origin-bottom-right[data-flat-pack--modal-origin-value='trigger']"
    assert_select "#origin-table-row[data-flat-pack--modal-origin-value='trigger']"
    assert_select "#origin-page-scroll[data-flat-pack--modal-origin-value='trigger'][data-fp-modal-scroll='page']"
    assert_select "#gallery-editor-from-button[data-controller='flat-pack--modal flat-pack--navigable'][data-flat-pack--modal-origin-value='trigger']"
  end

  test "gallery screen wraps the matching turbo-frame" do
    get "/demo/modals/gallery_editor"

    assert_response :success
    assert_select "turbo-frame#gallery-editor-screen"
    assert_select "[data-fp-screen][data-title='Gallery']"
    assert_includes response.body, "Harbour at dusk"
    assert_includes response.body, 'data-fp-nav="push"'
    assert_includes response.body, "This link is broken"
    refute_includes response.body, "ViewComponent"
    refute_includes response.body, "recordable"
  end

  test "edit image screen carries title footer and photographer link" do
    get "/demo/modals/gallery_editor/harbour"

    assert_response :success
    assert_select "turbo-frame#gallery-editor-screen"
    assert_select "[data-fp-screen][data-title='Edit image']"
    assert_select "[data-fp-screen-footer]"
    assert_includes response.body, "Caption"
    assert_includes response.body, "Alt text"
    assert_includes response.body, "Mira Chen"
    assert_includes response.body, 'data-fp-nav="push"'
    assert_includes response.body, 'data-fp-nav="back"'
    assert_includes response.body, 'data-fp-nav="reset"'
  end

  test "photographer screen is a later step in the same frame" do
    get "/demo/modals/gallery_editor/harbour/photographer"

    assert_response :success
    assert_select "turbo-frame#gallery-editor-screen"
    assert_select "[data-fp-screen][data-title='Edit photographer']"
    assert_includes response.body, "Mira Chen"
    assert_includes response.body, "Bio"
    assert_includes response.body, 'data-fp-nav="back"'
  end

  test "broken screen does not return a matching frame" do
    get "/demo/modals/gallery_editor/missing"

    assert_response :not_found
    refute_includes response.body, "gallery-editor-screen"
  end
end
