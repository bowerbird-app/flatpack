# frozen_string_literal: true

require "test_helper"

class PagesDemoRoutesTest < ActionDispatch::IntegrationTest
  DEMO_PATHS = %w[
    /demo
    /demo/buttons
    /demo/forms
    /demo/forms/text_input
    /demo/forms/password_input
    /demo/forms/email_input
    /demo/forms/phone_input
    /demo/forms/search_input
    /demo/forms/url_input
    /demo/forms/text_area
    /demo/forms/number_input
    /demo/forms/date_input
    /demo/forms/file_input
    /demo/forms/checkbox
    /demo/forms/radio_group
    /demo/forms/select
    /demo/forms/switch
    /demo/forms/combined
    /demo/inputs
    /demo/badges
    /demo/chips
    /demo/alerts
    /demo/cards
    /demo/breadcrumbs
    /demo/navbar
    /demo/search
    /demo/sidebar_layout
    /demo/sidebar/basic
    /demo/sidebar/header
    /demo/sidebar/footer
    /demo/sidebar/badges
    /demo/sidebar/grouped
    /demo/sidebar/collapsible
    /demo/sidebar/collapsed
    /demo/sidebar/complete
    /demo/modals
    /demo/popovers
    /demo/tooltips
    /demo/tabs
    /demo/tabs/pills
    /demo/tabs/stacked_pills
    /demo/toasts
    /demo/page_header
    /demo/empty_state
    /demo/grid
    /demo/pagination
    /demo/charts
    /demo/code_blocks
    /demo/avatars
    /demo/comments
    /demo/chat/demo
    /demo/chat/layout
    /demo/chat/panel
    /demo/chat/message_list
    /demo/chat/message_group
    /demo/chat/message
    /demo/chat/message_meta
    /demo/chat/attachment
    /demo/chat/date_divider
    /demo/chat/typing_indicator
    /demo/chat/composer
    /demo/chat/textarea
    /demo/chat/send_button
    /demo/progress
    /demo/collapse
    /demo/range_input
    /demo/skeletons
    /demo/list
    /demo/timeline
    /mobile
    /mobile/bottom_nav
  ].freeze

  test "demo pages respond successfully" do
    DEMO_PATHS.each do |path|
      get path
      assert_response :success, "Expected #{path} to return success"
    end
  end

  test "search results returns empty array for blank query" do
    get "/demo/search_results", params: {q: "   "}

    assert_response :success
    payload = JSON.parse(response.body)
    assert_equal [], payload["results"]
  end

  test "search results returns matching entries" do
    get "/demo/search_results", params: {q: "button"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"].to_s.include?("Button") }
  end

  test "form demo submission endpoints redirect" do
    post "/demo/forms/create"
    assert_redirected_to demo_forms_path

    patch "/demo/forms/update"
    assert_redirected_to demo_forms_path

    put "/demo/forms/update"
    assert_redirected_to demo_forms_path

    delete "/demo/forms/destroy"
    assert_redirected_to demo_forms_path
  end
end
