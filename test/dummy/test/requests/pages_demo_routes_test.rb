# frozen_string_literal: true

require "test_helper"

class PagesDemoRoutesTest < ActionDispatch::IntegrationTest
  DEMO_PATHS = %w[
    /demo
    /demo/buttons
    /demo/links
    /demo/buttons/pills
    /demo/buttons/segmented
    /demo/buttons/groups
    /demo/buttons/dropdowns
    /demo/billing
    /demo/billing/plan_summary
    /demo/billing/plan_picker
    /demo/billing/usage_meter
    /demo/billing/payment_method
    /demo/billing/invoice_list
    /demo/billing/status_alert
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
    /demo/forms/date_range_input
    /demo/forms/date_time_input
    /demo/forms/time_input
    /demo/forms/file_input
    /demo/forms/checkbox
    /demo/forms/radio_group
    /demo/forms/select
    /demo/forms/nested_multiselect
    /demo/forms/switch
    /demo/forms/combined
    /demo/badges
    /demo/chips
    /demo/chip_groups
    /demo/color_swatches
    /demo/font_swatches
    /demo/overflow_row
    /demo/divider
    /demo/alerts
    /demo/cards
    /demo/cards/styles
    /demo/cards/media
    /demo/cards/composed
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
    /demo/email/button
    /demo/email/card
    /demo/email/footer_links
    /demo/email/template_example
    /demo/modals
    /demo/popovers
    /demo/tooltips
    /demo/tabs
    /demo/tabs/pills
    /demo/tabs/stacked_pills
    /demo/toasts
    /demo/page_header
    /demo/page_nav
    /demo/text/content
    /demo/text/quote
    /demo/empty_state
    /demo/grid
    /demo/grid/movable_cards
    /demo/pagination
    /demo/admin
    /demo/charts
    /demo/charts/types
    /demo/charts/composition
    /demo/charts/setup
    /demo/charts/default_filter
    /demo/modal_filter
    /demo/code_blocks
    /demo/avatars
    /demo/avatar_groups
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
    /demo/accordion
    /demo/range_input
    /demo/skeletons
    /demo/list
    /demo/tree
    /demo/timeline
    /demo/timestamp
    /demo/local_time
    /demo/red_dot
    /demo/notification
    /mobile
    /mobile/bottom_nav
  ].freeze

  test "demo pages respond successfully" do
    DEMO_PATHS.each do |path|
      get path
      assert_response :success, "Expected #{path} to return success"
    end
  end

  test "list demo renders orderable event listener example" do
    get "/demo/list"

    assert_response :success
    assert_includes response.body, "Listen for Orderable Events"
    assert_includes response.body, "list:saved"
    assert_includes response.body, "list:error"
  end

  test "tables draggable demo renders event listener example" do
    get "/demo/tables/draggable"

    assert_response :success
    assert_includes response.body, "Listen for Table Events"
    assert_includes response.body, "table:reordered"
    assert_includes response.body, "flat-pack--table-sortable:saved"
  end

  test "tables basic demo renders filter and search control sections" do
    get "/demo/tables/basic"

    assert_response :success
    assert_includes response.body, "Table with Generic Filter Controls"
    assert_includes response.body, "Single Outer Frame with Multiple Table Controls"
    assert_includes response.body, "Search table rows..."
    assert_includes response.body, "Search both tables..."
  end

  test "avatars demo renders no tooltip example" do
    get "/demo/avatars"

    assert_response :success
    assert_includes response.body, "Avatar Tooltips (ERB)"
    assert_includes response.body, "No Tooltip"
    assert_includes response.body, "show_tooltip: false"
  end

  test "modal filter demo renders inline filters table example" do
    get "/demo/modal_filter"

    assert_response :success
    assert_includes response.body, "Table Example with Inline Filters"
    assert_includes response.body, "Status"
    assert_includes response.body, "Category"
    assert_includes response.body, "Filter"
  end

  test "date input demo renders billing anchor date with native picker" do
    get "/demo/forms/date_input"

    assert_response :success
    assert_select "p[id^='birth_date_'][id$='_help_text']", text: "Future dates are not accepted for birth dates."
    assert_select "input[name='birth_date'][aria-describedby]"
    assert_includes response.body, "picker: :native"
    assert_includes response.body, "name: &quot;billing_anchor_date&quot;"
    assert_includes response.body, "component-method-variables-date_input-0"
  end

  test "date time input demo does not include the date range companion example" do
    get "/demo/forms/date_time_input"

    assert_response :success
    assert_includes response.body, "component-method-variables-date_time_input-0"
    refute_includes response.body, "Date Range Companion Example"
    refute_includes response.body, "component-method-variables-date_input-0"
  end

  test "nested multiselect demo renders controller example and sidebar link" do
    get "/demo/forms/nested_multiselect"

    assert_response :success
    assert_includes response.body, "Nested Multiselect"
    assert_includes response.body, 'data-controller="flat-pack--nested-multiselect"'
    assert_includes response.body, 'href="/demo/forms/nested_multiselect"'
    assert_includes response.body, "locations[]"
  end

  test "sidebar renders email section with new component links" do
    get "/demo/email/template_example"

    assert_response :success
    assert_includes response.body, "Email"
    assert_includes response.body, 'href="/demo/email/button"'
    assert_includes response.body, 'href="/demo/email/card"'
    assert_includes response.body, 'href="/demo/email/footer_links"'
    assert_includes response.body, 'href="/demo/email/template_example"'
  end

  test "admin demo renders pagination" do
    get "/demo/admin"

    assert_response :success
    assert_includes response.body, "Filter"
    assert_includes response.body, 'aria-label="Pagination"'
    assert_includes response.body, "?page=2"
  end

  test "buttons demo links to pill and group sibling pages" do
    get "/demo/buttons"

    assert_response :success
    assert_includes response.body, "Pill Buttons"
    assert_includes response.body, demo_buttons_pills_path
    assert_includes response.body, demo_buttons_groups_path
    assert_includes response.body, demo_buttons_segmented_path
    assert_includes response.body, demo_buttons_dropdowns_path
  end

  test "buttons related demos render after theme tokens" do
    get "/demo/buttons"

    assert_response :success
    theme_at = response.body.index("id=\"theme-tokens\"")
    related_at = response.body.index("id=\"related-demos\"")

    assert theme_at, "expected Theme Tokens section"
    assert related_at, "expected Related demos section"
    assert_operator related_at, :>, theme_at
  end

  test "billing demo links to sibling billing pages" do
    get "/demo/billing"

    assert_response :success
    assert_includes response.body, "Billing Components"
    assert_includes response.body, demo_billing_plan_summary_path
    assert_includes response.body, demo_billing_plan_picker_path
    assert_includes response.body, demo_billing_usage_meter_path
    assert_includes response.body, demo_billing_payment_method_path
    assert_includes response.body, demo_billing_invoice_list_path
    assert_includes response.body, demo_billing_status_alert_path
    assert_includes response.body, "Plan Summary"
    assert_includes response.body, "Visa"
  end

  test "billing plan summary demo renders status variants" do
    get "/demo/billing/plan_summary"

    assert_response :success
    assert_includes response.body, "Plan Summary"
    assert_includes response.body, demo_billing_path
    assert_includes response.body, "Active"
    assert_includes response.body, "Past due"
  end

  test "collapse and accordion demos link to each other" do
    get "/demo/collapse"
    assert_response :success
    assert_includes response.body, demo_accordion_path

    get "/demo/accordion"
    assert_response :success
    assert_includes response.body, demo_collapse_path
  end

  test "pill buttons demo renders pill button examples" do
    get "/demo/buttons/pills"

    assert_response :success
    assert_includes response.body, "Pill Buttons"
    assert_includes response.body, "Same-page anchors without a reload"
    assert_includes response.body, 'data-controller="pill-buttons-demo"'
    assert_includes response.body, "pill-anchor-account"
    assert_includes response.body, 'data-action="pill-buttons-demo#activate"'
    assert_includes response.body, "/demo/tabs/pills#account"
    assert_includes response.body, "Team Members"
    assert_includes response.body, 'aria-current="page"'
  end

  test "segmented and grouped button demos render examples" do
    get "/demo/buttons/segmented"

    assert_response :success
    assert_includes response.body, 'data-controller="segmented-buttons-demo"'
    assert_includes response.body, 'data-action="segmented-buttons-demo#activate"'
    assert_includes response.body, 'aria-pressed="true"'

    get "/demo/buttons/groups"

    assert_response :success
    assert_includes response.body, "Button Groups (Wrapped Together)"
    assert_includes response.body, "Left"
    assert_includes response.body, "Middle"
  end

  test "page nav demo renders icon-only navigation" do
    get "/demo/page_nav"

    assert_response :success
    assert_includes response.body, "Page Nav Component"
    assert_includes response.body, "flat-pack--page-nav#back"
    assert_includes response.body, "x-mark"
    assert_includes response.body, "plus"
  end

  test "comments demo renders rich text composer examples" do
    get "/demo/comments"

    assert_response :success
    assert_includes response.body, "Rich Text Composer Variants"
    assert_includes response.body, "Rich text with toolbar"
    assert_includes response.body, "Rich text with bubble menu"
    assert_includes response.body, 'name="toolbar_comment[body]"'
    assert_includes response.body, 'name="bubble_comment[body]"'
    assert_includes response.body, 'data-controller="flat-pack--tiptap"'
  end

  test "collapse demo renders component variables tables" do
    get "/demo/collapse"

    assert_response :success
    assert_includes response.body, "Method Call"
    assert_includes response.body, "Variable"
    assert_includes response.body, "Accepts"
    assert_includes response.body, "Example"
    assert_includes response.body, "render FlatPack::Collapse::Component.new"
    assert_includes response.body, "left_slot"
    refute_includes response.body, "render FlatPack::Accordion::Component.new"
  end

  test "accordion demo renders accordion examples" do
    get "/demo/accordion"

    assert_response :success
    assert_includes response.body, "render FlatPack::Accordion::Component.new"
    assert_includes response.body, "Allow Multiple Open"
  end

  test "cards media demo renders media gallery example" do
    get "/demo/cards/media"

    assert_response :success
    assert_includes response.body, "Media Gallery Cards"
    assert_includes response.body, "IMG_4985.HEIC"
    assert_includes response.body, "View details for IMG_5644.HEIC"
    assert_includes response.body, "Select IMG_4985.HEIC"
    assert_includes response.body, "Edit IMG_4985.HEIC"
    assert_includes response.body, "Delete IMG_4985.HEIC"
    assert_includes response.body, "group-hover:opacity-100"
    assert_includes response.body, "has-[:checked]:ring-2"
    assert_includes response.body, "ring-[var(--color-primary)]"
    refute_includes response.body, "ring-indigo-600"
    refute_includes response.body, "ring-indigo-500"
    refute_includes response.body, "dark:ring-offset-gray-950"
    refute_includes response.body, "outline-black/5"
    assert_includes response.body, 'class="flex-1 overflow-hidden pointer-events-none px-3 py-2"'
    refute_includes response.body, "p-[var(--card-padding-md)] flex-1 overflow-hidden pointer-events-none px-3 py-2"
    assert_includes response.body, "&quot;style&quot; =&gt; &quot;background-color: transparent&quot;"
    refute_includes response.body, "style: &quot;background-color: transparent&quot;"
  end

  test "dummy importmap includes tiptap package pins" do
    importmap = File.read(Rails.root.join("config/importmap.rb"))

    assert_includes importmap, 'pin "@tiptap/core", to: "https://esm.sh/@tiptap/core@#{TIPTAP_VERSION}"'
    assert_includes importmap, 'pin "@tiptap/extension-bubble-menu", to: "https://esm.sh/@tiptap/extension-bubble-menu@#{TIPTAP_VERSION}"'
    assert_includes importmap, 'pin "@tiptap/extension-table-of-contents", to: "https://esm.sh/@tiptap/extension-table-of-contents@#{TIPTAP_VERSION}"'
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
    assert_includes response.body, "confirm_label: &quot;Use Inline Selection&quot;"
    assert_includes response.body, "results_layout: :grid"
    assert_includes response.body, "confirm_label: &quot;Use Asset&quot;"
    assert_includes response.body, "confirm_label: &quot;Use Folder&quot;"
    assert_includes response.body, "confirm_label: &quot;Store Selection&quot;"
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

  test "legacy inputs demo redirects to forms" do
    get "/demo/inputs"

    assert_redirected_to "/demo/forms"
  end

  test "text input demo includes help text in rendered examples and code snippets" do
    get "/demo/forms/text_input"

    assert_response :success
    assert_includes response.body, "help_text"
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

  test "text content demo renders long-form marketing copy" do
    get "/demo/text/content"

    assert_response :success
    assert_includes response.body, ">Content</h1>"
    assert_includes response.body, ">A Mastered Workflow</h1>"
    assert_includes response.body, "text-(--color-primary)"
    assert_includes response.body, "One-Click Distribution."
    assert_includes response.body, "No Publisher? No Problem."
  end

  test "range input demo variable table includes full option set" do
    get "/demo/range_input"

    assert_response :success
    assert_includes response.body, ">min</td>"
    assert_includes response.body, ">max</td>"
    assert_includes response.body, ">step</td>"
    assert_includes response.body, "**system_arguments"
  end

  test "notification demo renders the notification component examples" do
    get "/demo/notification"

    assert_response :success
    assert_includes response.body, "Notification Component"
    assert_includes response.body, "Badge states"
    assert_includes response.body, "Recent notifications"
    assert_includes response.body, "data-controller=\"flat-pack--popover\""
    assert_includes response.body, "data-controller=\"flat-pack--timestamp\""
    assert_includes response.body, "Rollup notifications"
    assert_includes response.body, "flat-pack--notification-rollup"
    assert_includes response.body, "Build artifact uploaded"
    assert_includes response.body, "Build delivered"
    assert_includes response.body, "Code Example"
    assert_includes response.body, "rollup_notifications = ["
    assert_includes response.body, "See all notifications"
    assert_includes response.body, "9+"
  end

  test "red dot demo renders helper utility examples and helpers section" do
    get "/demo/red_dot"

    assert_response :success
    assert_includes response.body, "Red Dot Utility"
    assert_includes response.body, "Basic Usage"
    assert_includes response.body, "Theme And Positioning"
    assert_includes response.body, "fp-red-dot"
    assert_includes response.body, "Helpers"
    assert_includes response.body, "Local Time"
    assert_includes response.body, "Red Dot"
    assert_includes response.body, 'href="/demo/local_time"'
    assert_includes response.body, 'href="/demo/red_dot"'
  end

  test "progress demo variable table includes core options" do
    get "/demo/progress"

    assert_response :success
    assert_includes response.body, ">value</td>"
    assert_includes response.body, ">style</td>"
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
    assert_includes response.body, ">items</td>"
    assert_includes response.body, ">max_width</td>"
    assert_includes response.body, ">min_characters</td>"
    assert_includes response.body, ">debounce</td>"
    assert_includes response.body, ">no_results_text</td>"
    assert_includes response.body, "**system_arguments"
  end

  test "search demo shows local catalog before remote JSON" do
    get "/demo/search"

    assert_response :success
    assert_includes response.body, "Local catalog"
    assert_includes response.body, "data-flat-pack--search-items-value"
    assert_includes response.body, "Try form, accordion, or chart..."
    assert_includes response.body, "Remote JSON"
    assert_includes response.body, "data-flat-pack--search-url-value=\"/demo/search_results\""
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

  test "search results rank form pages ahead of tables" do
    get "/demo/search_results", params: {q: "form"}

    assert_response :success
    payload = JSON.parse(response.body)
    titles = payload.fetch("results").map { |entry| entry["title"] }

    assert titles.first.to_s.downcase.include?("form")
    refute_equal "Tables", titles.first
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

    get "/demo/search_results", params: {q: "folder tree"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"] == "Tree" }
  end

  test "search results include accordion and chart composition pages" do
    get "/demo/search_results", params: {q: "accordion"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"] == "Accordion" }

    get "/demo/search_results", params: {q: "composition"}

    assert_response :success
    payload = JSON.parse(response.body)
    assert payload["results"].any? { |entry| entry["title"].to_s.include?("Composition") }
  end

  test "top nav includes live demo search" do
    get "/demo"

    assert_response :success
    assert_includes response.body, "Search demo pages..."
    assert_match(/data-controller="[^"]*flat-pack--search[^"]*"/, response.body)
    assert_includes response.body, "data-flat-pack--search-items-value"
    assert_includes response.body, "Accordion"
    assert_includes response.body, "data-flat-pack--icon-name-value=\"magnifying-glass\""
    assert_includes response.body, "-translate-y-0.5"
    refute_includes response.body, "data-flat-pack--search-url-value=\"/demo/search_results\""
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
