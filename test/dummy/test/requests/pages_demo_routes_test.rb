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
    /demo/picker
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
    /demo/text/quote
    /demo/empty_state
    /demo/grid
    /demo/grid/movable_cards
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
    /demo/chat/sent_message
    /demo/chat/received_message
    /demo/chat/file_message
    /demo/chat/image_message
    /demo/chat/system_message
    /demo/chat/image_deck
    /demo/chat/message_record
    /demo/chat/inbox_row
    /demo/chat/message_meta
    /demo/chat/attachment
    /demo/chat/date_divider
    /demo/chat/typing_indicator
    /demo/chat/composer
    /demo/chat/textarea
    /demo/chat/send_button
    /demo/carousel
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

  test "chat demo keeps composer visible in full-height panel" do
    get "/demo/chat/demo"

    assert_response :success
    assert_includes response.body, "id=\"chat-demo-panel\""
    assert_includes response.body, "class=\"block h-full\""
    assert_includes response.body, "data-controller=\"flat-pack--chat-sender\""
    assert_includes response.body, "modal-id=\"chat-picker-images\""
    assert_includes response.body, "modal-id=\"chat-picker-files\""
    assert_includes response.body, "id=\"chat-picker-images\""
    assert_includes response.body, "id=\"chat-picker-files\""
    assert_includes response.body, "flat-pack:picker:confirm@document-&gt;flat-pack--chat-sender#handlePickerConfirm"
    assert_includes response.body, "data-flat-pack--chat-sender-optimistic-endpoint-value=\"/demo/chat_groups/"
    assert_includes response.body, "data-flat-pack--chat-sender-picker-ids-value=\"[&quot;chat-picker-images&quot;,&quot;chat-picker-files&quot;]\""
  end

  test "picker demo renders reusable picker component examples" do
    get "/demo/picker"

    assert_response :success
    assert_includes response.body, "Open Local Picker"
    assert_includes response.body, "Open Image Picker"
    assert_includes response.body, "id=\"picker-demo-local\""
    assert_includes response.body, "id=\"picker-demo-images\""
    assert_includes response.body, "id=\"picker-demo-remote\""
    assert_includes response.body, "id=\"picker-demo-field\""
    assert_includes response.body, "data-controller=\"picker-demo\""
  end

  test "text input demo variable table includes value option" do
    get "/demo/forms/text_input"

    assert_response :success
    assert_includes response.body, "<td class=\"px-4 py-3 text-sm text-primary font-medium\">value</td>"
    assert_includes response.body, "value: &quot;john.doe&quot;"
  end

  test "page header demo includes all page title heading variants" do
    get "/demo/page_header"

    assert_response :success
    assert_includes response.body, ">Heading Variant H1</h1>"
    assert_includes response.body, ">Heading Variant H2</h2>"
    assert_includes response.body, ">Heading Variant H3</h3>"
    assert_includes response.body, ">Heading Variant H4</h4>"
    assert_includes response.body, ">Heading Variant H5</h5>"
    assert_includes response.body, ">Heading Variant H6</h6>"
    assert_includes response.body, "--page-title-h1-size"
    assert_includes response.body, "--page-title-h6-size"
  end

  test "range input demo variable table includes full option set" do
    get "/demo/range_input"

    assert_response :success
    assert_includes response.body, ">min</td>"
    assert_includes response.body, ">max</td>"
    assert_includes response.body, ">step</td>"
    assert_includes response.body, "**system_arguments"
  end

  test "progress demo variable table includes core options" do
    get "/demo/progress"

    assert_response :success
    assert_includes response.body, ">value</td>"
    assert_includes response.body, ">variant</td>"
    assert_includes response.body, ">size</td>"
    assert_includes response.body, "show_label: true"
    assert_includes response.body, "Theme Tokens"
    assert_includes response.body, "--surface-muted-background-color"
    assert_includes response.body, "--color-success-background-color"
  end

  test "carousel demo renders lightbox control and footer counter copy" do
    get "/demo/carousel"

    assert_response :success
    assert_includes response.body, "data-flat-pack--carousel-target=\"counter\""
    assert_includes response.body, "data-flat-pack--carousel-target=\"lightboxToggle\""
    assert_includes response.body, "The slide count now sits in the bottom-right footer beside the dot navigation."
  end

  test "search demo variable table includes full option set" do
    get "/demo/search"

    assert_response :success
    assert_includes response.body, ">placeholder</td>"
    assert_includes response.body, ">name</td>"
    assert_includes response.body, ">value</td>"
    assert_includes response.body, ">search_url</td>"
    assert_includes response.body, ">max_width</td>"
    assert_includes response.body, ">min_characters</td>"
    assert_includes response.body, ">debounce</td>"
    assert_includes response.body, ">no_results_text</td>"
    assert_includes response.body, "**system_arguments"
  end

  test "select demo uses overflow-visible card for searchable dropdowns" do
    get "/demo/forms/select"

    assert_response :success
    assert_includes response.body, "flat-pack-select-trigger"
    assert_includes response.body, "overflow-visible"
  end

  test "chat demo inbox renders compact chat group avatar clusters" do
    get "/demo/chat/demo"

    assert_response :success
    assert_includes response.body, "data-chat-group-inbox-avatar=\"true\""
    assert_includes response.body, "data-max-visible-avatars=\"2\""
  end

  test "chat file message demo exposes real file download links" do
    get "/demo/chat/file_message"

    assert_response :success
    assert_includes response.body, "/demo/chat/files/launch-plan"
    assert_includes response.body, "/demo/chat/files/qa-checklist"
  end

  test "chat file download returns attachment content" do
    get "/demo/chat/files/launch-plan"

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert_includes response.headers["Content-Disposition"], "attachment"
    assert_includes response.headers["Content-Disposition"], "launch-plan.pdf"
    assert_includes response.body, "Demo launch plan PDF"
  end

  test "chat inbox row demo renders reusable row examples" do
    get "/demo/chat/inbox_row"

    assert_response :success
    assert_includes response.body, "Chat::InboxRow"
    assert_includes response.body, "Design Team"
    assert_includes response.body, "data-chat-group-inbox-avatar=\"true\""
  end

  test "carousel page renders rebuilt component demo" do
    get "/demo/carousel"

    assert_response :success
    assert_includes response.body, "Carousel Component"
    assert_includes response.body, "Basic Carousel"
    assert_includes response.body, "Carousel with Thumbnails and Autoplay"
    assert_includes response.body, "Fade Transition"
    assert_includes response.body, "data-controller=\"flat-pack--carousel\""
    assert_includes response.body, "Examples for Basic Carousel"
    assert_includes response.body, ">Variable</th>"
    assert_includes response.body, ">Accepts</th>"
    assert_includes response.body, ">Example</th>"
    assert_includes response.body, "Theme Tokens"
    assert_includes response.body, "--carousel-viewport-background-color"
  end

  test "sidebar includes carousel demo entry" do
    get "/demo/carousel"

    assert_response :success
    assert_includes response.body, "Carousel"
    assert_includes response.body, "/demo/carousel"
    refute_includes response.body, "/demo/carousel/images"
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

  test "search results include movable cards grid entry" do
    get "/demo/search_results", params: {q: "movable cards"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"].to_s.include?("Grid: Movable Cards") }
  end

  test "search results include sidebar section pages like themes and timeline" do
    get "/demo/search_results", params: {q: "ocean theme"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"] == "Ocean theme" }

    get "/demo/search_results", params: {q: "timeline"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"] == "Timeline" }
  end

  test "top nav includes live demo search" do
    get "/demo"

    assert_response :success
    assert_includes response.body, "Search demo pages..."
    assert_includes response.body, "data-controller=\"flat-pack--search\""
    assert_includes response.body, "data-flat-pack--search-url-value=\"/demo/search_results\""
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
