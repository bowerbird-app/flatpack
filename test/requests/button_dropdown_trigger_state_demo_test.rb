# frozen_string_literal: true

require "test_helper"

class ButtonDropdownTriggerStateDemoTest < ActionDispatch::IntegrationTest
  test "the dropdown demo renders the publish status state node" do
    get "/demo/buttons/dropdowns"

    assert_response :success
    assert_select "#publish-status-dropdown button.fp-button-dropdown__trigger[data-fp-style=secondary]", text: "Draft"
    assert_select "#publish-status-state[hidden][data-flat-pack--button-dropdown-target=triggerState][data-style=secondary][data-press=flat][data-label=Draft]", count: 1
    assert_select "#publish-status-menu form[data-flat-pack-dropdown-keep-open] button[name=status][value=published]", text: "Published"
    assert_includes response.body, "with_trigger_state"
    assert_includes response.body, "turbo_stream.replace"
  end

  test "posting a status replaces the state node" do
    post "/demo/buttons/dropdowns/status", params: {status: "published"}, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_includes response.body, 'action="replace"'
    assert_includes response.body, 'target="publish-status-state"'
    assert_includes response.body, 'id="publish-status-state"'
    assert_includes response.body, 'data-style="success"'
    assert_includes response.body, 'data-press="raised"'
    assert_includes response.body, 'data-label="Published"'
    assert_includes response.body, 'data-flat-pack--button-dropdown-target="triggerState"'
  end

  test "an unknown status falls back to draft" do
    post "/demo/buttons/dropdowns/status", params: {status: "nope"}, as: :turbo_stream

    assert_response :success
    assert_includes response.body, 'data-style="secondary"'
    assert_includes response.body, 'data-press="flat"'
    assert_includes response.body, 'data-label="Draft"'
  end

  test "an html post returns to the demo" do
    post "/demo/buttons/dropdowns/status", params: {status: "published"}

    assert_redirected_to "/demo/buttons/dropdowns#publish-status"
  end
end
