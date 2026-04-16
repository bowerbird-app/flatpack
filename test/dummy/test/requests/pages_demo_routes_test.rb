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
    /demo/chat/images
    /demo/chat/system_message
    /demo/chat/inbox_row
    /demo/chat/attachment
    /demo/chat/date_divider
    /demo/chat/typing_indicator
    /demo/chat/composer
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

  test "tooltips demo uses dummy app default icon variant" do
    get "/demo/tooltips"

    assert_response :success
    assert_includes response.body, 'data-flat-pack--icon-variant-value="outline"'
    assert_includes response.body, 'viewBox="0 0 24 24"'
  end

  test "chips demo includes removable callback example" do
    get "/demo/chips"

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_includes response.body, 'id="removable-failed-callback-chips-container"'
    assert_includes response.body, 'data-flat-pack--chip-remove-url-value="/demo/chips/remove_callback"'
    assert_includes response.body, 'data-flat-pack--chip-remove-method-value="get"'
    assert_includes response.body, "data-flat-pack--chip-remove-params-value="
    assert_includes response.body, "&quot;tag&quot;:&quot;ruby&quot;,&quot;source&quot;:&quot;chips_demo&quot;"
    assert_includes response.body, "&quot;tag&quot;:&quot;rails&quot;,&quot;source&quot;:&quot;chips_demo&quot;"
    assert_includes response.body, 'data-flat-pack--chip-remove-method-value="post"'
    assert_includes response.body, "&quot;fail&quot;:true"
    assert_includes response.body, 'data-controller="flat-pack--chip-tag-input"'
    assert_includes response.body, "keydown-&gt;flat-pack--chip-tag-input#handleKeydown"
    assert_includes response.body, 'data-flat-pack--chip-tag-input-target="template"'
    assert_includes response.body, 'data-flat-pack--chip-tag-input-auto-submit-value="true"'
    assert_includes response.body, 'data-flat-pack--chip-tag-input-add-url-value="/demo/chips/add_callback"'
    assert_includes response.body, "&quot;mode&quot;:&quot;auto&quot;"
    assert_includes response.body, "&quot;tag&quot;:&quot;frontend&quot;,&quot;source&quot;:&quot;chips_demo_local&quot;"
    assert_includes response.body, "&quot;tag&quot;:&quot;api&quot;,&quot;source&quot;:&quot;chips_demo_auto&quot;"
    assert_includes response.body, "&quot;tag&quot;:&quot;__TAG_VALUE__&quot;,&quot;source&quot;:&quot;chips_demo_auto&quot;"
  end

  test "chip add callback endpoint accepts get and post" do
    get "/demo/chips/add_callback", params: {text: "API Platform", value: "api-platform", source: "chips_demo"}

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal({"ok" => true, "method" => "GET", "params" => {"text" => "API Platform", "value" => "api-platform", "source" => "chips_demo"}}, JSON.parse(response.body))

    post "/demo/chips/add_callback", params: {text: "API Platform", value: "api-platform", source: "chips_demo"}, as: :json

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal({"ok" => true, "method" => "POST", "params" => {"text" => "API Platform", "value" => "api-platform", "source" => "chips_demo"}}, JSON.parse(response.body))
  end

  test "chip add callback endpoint can reject an addition" do
    post "/demo/chips/add_callback", params: {text: "Blocked", value: "blocked", source: "chips_demo", fail: true}, as: :json

    assert_response :unprocessable_entity
    assert_equal({"ok" => false, "error" => "Add denied", "params" => {"text" => "Blocked", "value" => "blocked", "source" => "chips_demo"}}, JSON.parse(response.body))
  end

  test "chip removal callback endpoint accepts get and post" do
    get "/demo/chips/remove_callback", params: {tag: "ruby", source: "chips_demo"}

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal({"ok" => true, "method" => "GET", "params" => {"tag" => "ruby", "source" => "chips_demo"}}, JSON.parse(response.body))

    post "/demo/chips/remove_callback", params: {tag: "ruby", source: "chips_demo"}, as: :json

    assert_response :success
    assert_includes response.headers["Cache-Control"], "no-store"
    assert_equal({"ok" => true, "method" => "POST", "params" => {"tag" => "ruby", "source" => "chips_demo"}}, JSON.parse(response.body))
  end

  test "chip removal callback endpoint can reject a removal" do
    post "/demo/chips/remove_callback", params: {tag: "ruby", source: "chips_demo", fail: true}, as: :json

    assert_response :unprocessable_entity
    assert_equal({"ok" => false, "error" => "Removal denied", "params" => {"tag" => "ruby", "source" => "chips_demo"}}, JSON.parse(response.body))
  end

  test "dummy layouts load the compiled application stylesheet" do
    get "/"

    assert_response :success
    assert_includes response.body, 'href="/assets/application-'
    assert_includes response.body, 'href="/assets/flat_pack/variables-'
    refute_includes response.body, 'href="/assets/tailwind-'
  end

  test "standalone chat message meta demo route is not exposed" do
    get "/demo/chat/message_meta"

    assert_response :not_found
  end

  test "picker demo renders reusable picker component examples" do
    get "/demo/picker"

    assert_response :success
    assert_includes response.body, "Required Data"
    assert_includes response.body, "Local items array"
    assert_includes response.body, "Remote search JSON"
    assert_includes response.body, "name</code> is required"
    assert_includes response.body, "signed_id: &quot;blob-signed-id-123&quot;"
    assert_includes response.body, "record_id: 42"
    assert_includes response.body, "&quot;kind&quot;: &quot;record&quot;"
    assert_includes response.body, "Open Local Picker"
    assert_includes response.body, "Open Auto-Confirm Picker"
    assert_includes response.body, "Open Image Picker"
    assert_includes response.body, "Open Folder Picker"
    assert_includes response.body, "Search Visibility"
    assert_includes response.body, "Explicit Hard Off"
    assert_includes response.body, "Thresholded Local Search"
    assert_includes response.body, "Built-in Form Submission"
    assert_includes response.body, "Items Height"
    assert_includes response.body, "items-height-min-content"
    assert_includes response.body, "items-height-max-content"
    assert_includes response.body, "items-height-fixed-height"
    assert_includes response.body, "searchable: false"
    assert_includes response.body, "minimum_searchable: 5"
    assert_includes response.body, "picker-demo-code-required-data-local-items"
    assert_includes response.body, "picker-demo-code-search-visibility-erb"
    assert_includes response.body, "picker-demo-code-field-output-erb"
    assert_includes response.body, "View ERB Code"
    assert_includes response.body, "View Controller Code"
    assert_includes response.body, "id=\"picker-demo-local\""
    assert_includes response.body, "id=\"picker-demo-built-in-form\""
    assert_includes response.body, "id=\"picker-demo-inline\""
    assert_includes response.body, "id=\"picker-demo-searchable-off\""
    assert_includes response.body, "id=\"picker-demo-minimum-searchable\""
    assert_includes response.body, "id=\"picker-demo-items-height-min\""
    assert_includes response.body, "id=\"picker-demo-items-height-max\""
    assert_includes response.body, "id=\"picker-demo-items-height-fixed\""
    assert_includes response.body, "id=\"picker-demo-images\""
    assert_includes response.body, "id=\"picker-demo-remote\""
    assert_includes response.body, "id=\"picker-demo-auto-confirm\""
    assert_includes response.body, "id=\"picker-demo-folders\""
    assert_includes response.body, "id=\"picker-demo-field\""
    assert_includes response.body, "id=\"picker-inline-selected-field\""
    assert_includes response.body, "id=\"picker-auto-confirm-field\""
    assert_includes response.body, "id=\"picker-folder-field\""
    assert_includes response.body, "data-controller=\"picker-demo\""
    assert_includes response.body, "id=\"picker-demo-inline\""
    assert_includes response.body, "output_target: &quot;#picker-inline-selected-field&quot;"
    assert_includes response.body, "accepted_kinds: [:image]"
    assert_includes response.body, "output_target: &quot;#picker-auto-confirm-field&quot;"
    assert_includes response.body, "accepted_kinds: [:record]"
    assert_includes response.body, "output_target: &quot;#picker-folder-field&quot;"
    assert_includes response.body, "output_target: &quot;#picker-selected-assets-field&quot;"
    assert_includes response.body, "value_path: &quot;payload.record_id&quot;"
    assert_includes response.body, "demo_picker_submissions_path"
    assert_includes response.body, "modal: true"
    assert_includes response.body, "confirm_text: &quot;Use Inline Selection&quot;"
    assert_includes response.body, "results_layout: :grid"
    assert_includes response.body, "confirm_text: &quot;Use Asset&quot;"
    assert_includes response.body, "confirm_text: &quot;Use Folder&quot;"
    assert_includes response.body, "confirm_text: &quot;Store Selection&quot;"
    assert_includes response.body, "items_height: &quot;min-content&quot;"
    assert_includes response.body, "items_height: &quot;max-content&quot;"
    assert_includes response.body, "items_height: &quot;240px&quot;"
    assert_includes response.body, "selection_mode: :single"

    assert_select "#picker-demo-auto-confirm .mt-4.flex.items-center.justify-end.gap-2", count: 0
    assert_select "#picker-demo-auto-confirm button", text: "Use Asset", count: 0
    assert_select "#picker-demo-items-height-min .mt-4.flex.items-center.justify-end.gap-2", count: 1
    assert_select "#picker-demo-items-height-min button", text: "Close", count: 1
    assert_select "#picker-demo-items-height-min button", text: "Use Asset", count: 1
  end

  test "picker built-in form submission redirects back with controller params" do
    post "/demo/picker_submissions", params: {
      picker_assignment: {
        folder_record_id: "42"
      }
    }

    assert_redirected_to "/demo/picker#built-in-form"

    follow_redirect!
    assert_response :success
    assert_includes response.body, "Last Controller Payload"
    assert_includes response.body, "params[:picker_assignment][:folder_record_id]"
    assert_includes response.body, ">42<"
  end

  test "picker results endpoint supports record kinds" do
    get "/demo/picker_results", params: {q: "brand", kinds: "record"}

    assert_response :success

    body = JSON.parse(response.body)
    assert_equal ["record"], body.fetch("items").map { |item| item.fetch("kind") }.uniq

    item = body.fetch("items").first
    assert_equal "Brand Assets", item.fetch("label")
    assert_equal "/Marketing/Brand Assets", item.fetch("path")
    assert_equal "Folder", item.fetch("badge")
    assert_equal({"record_type" => "Folder", "record_id" => 42}, item.fetch("payload"))
  end

  test "text input demo variable table includes value option" do
    get "/demo/forms/text_input"

    assert_response :success
    assert_includes response.body, ">value</td>"
    assert_includes response.body, "value: &quot;john.doe&quot;"
  end

  test "text input demo renders server error styling hooks" do
    get "/demo/forms/text_input"

    assert_response :success
    assert_includes response.body, "Username must be at least 5 characters"
    assert_includes response.body, "mt-1 text-sm text-warning"
    assert_includes response.body, "border-warning"
    assert_includes response.body, 'name="username_error"'
    assert_includes response.body, 'minlength="5"'
    assert_includes response.body, 'data-flat-pack-message-too-short="Username must be at least 5 characters"'
  end

  test "text input demo renders required field validation hooks" do
    get "/demo/forms/text_input"

    assert_response :success
    assert_includes response.body, 'name="username"'
    assert_includes response.body, 'required="required"'
    assert_includes response.body, 'data-controller="flat-pack--form-validation"'
    assert_includes response.body, "data-flat-pack--form-validation-error-id-value="
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
    assert_includes response.body, "Single Slide Example"
    assert_includes response.body, "With only one slide, the carousel keeps the content and lightbox expand button but skips the chevron controls, dot navigation, and slide count."
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
    assert_includes response.body, 'data-flat-pack-chat-record="true"'
    assert_includes response.body, 'data-flat-pack-chat-record-direction="incoming"'
    assert_includes response.body, "Footer links were re-ordered per legal review."
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

  test "legacy chat image demo routes redirect to consolidated images page" do
    get "/demo/chat/image_message"

    assert_redirected_to "/demo/chat/images"

    get "/demo/chat/image_deck"

    assert_redirected_to "/demo/chat/images"
  end

  test "chat images demo renders single-image and carousel examples" do
    get "/demo/chat/images"

    assert_response :success
    assert_includes response.body, "Chat::Images"
    assert_includes response.body, "Single Image Attachment"
    assert_includes response.body, "Gallery Using Carousel"
    assert_includes response.body, "data-controller=\"flat-pack--carousel\""
    assert_includes response.body, "Expand image"
    assert_equal 15, response.body.scan('data-flat-pack--carousel-target="slide"').size
    assert_equal 13, response.body.scan('data-flat-pack--carousel-target="thumb"').size
  end

  test "chat inbox row demo renders reusable row examples" do
    get "/demo/chat/inbox_row"

    assert_response :success
    assert_includes response.body, "Chat::InboxRow"
    assert_includes response.body, "Design Team"
    assert_includes response.body, "data-chat-group-inbox-avatar=\"true\""
    assert_includes response.body, "+2"
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
