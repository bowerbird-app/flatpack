# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: "users/sessions"}
  # Mount the FlatPack engine
  mount FlatPack::Engine => "/flat_pack"

  # Demo pages
  get "pages/hero"
  get "pages/hero/centered", to: "pages#hero_centered"
  get "pages/hero/centered_image", to: "pages#hero_centered_image"
  get "pages/hero/screenshot", to: "pages#hero_screenshot"
  get "pages/hero/split_image", to: "pages#hero_split_image"
  get "pages/hero/angled_image", to: "pages#hero_angled_image"
  get "pages/hero/image_tiles", to: "pages#hero_image_tiles"
  get "pages/hero/offset_image", to: "pages#hero_offset_image"
  get "demo", to: "pages#demo"
  get "themes", to: "themes#index"
  get "themes/demos/:theme", to: "themes#demo", as: :theme_demo,
    constraints: {theme: /system|light|dark|ocean|rounded/}
  get "demo/buttons", to: "pages#buttons"
  get "demo/forms", to: "pages#forms"
  get "demo/forms/text_input", to: "pages#forms_text_input"
  get "demo/forms/password_input", to: "pages#forms_password_input"
  get "demo/forms/email_input", to: "pages#forms_email_input"
  get "demo/forms/phone_input", to: "pages#forms_phone_input"
  get "demo/forms/search_input", to: "pages#forms_search_input"
  get "demo/forms/url_input", to: "pages#forms_url_input"
  get "demo/forms/text_area", to: "pages#forms_text_area"
  post "demo/forms/text_area", to: "pages#forms_text_area_submit"
  get "demo/forms/number_input", to: "pages#forms_number_input"
  get "demo/forms/date_input", to: "pages#forms_date_input"
  get "demo/forms/file_input", to: "pages#forms_file_input"
  get "demo/forms/checkbox", to: "pages#forms_checkbox"
  get "demo/forms/radio_group", to: "pages#forms_radio_group"
  get "demo/forms/select", to: "pages#forms_select"
  get "demo/forms/switch", to: "pages#forms_switch"
  get "demo/forms/combined", to: "pages#forms_combined"
  get "demo/tables/basic", to: "pages#tables_basic"
  get "demo/tables/empty", to: "pages#tables_empty"
  get "demo/tables/sortable", to: "pages#tables_sortable"
  get "demo/tables/draggable", to: "pages#tables_draggable"
  patch "demo/tables/reorder", to: "pages#tables_reorder"
  get "demo/inputs", to: "pages#inputs"
  get "demo/badges", to: "pages#badges"
  get "demo/chips", to: "pages#chips"
  match "demo/chips/add_callback", to: "pages#chip_add_callback", via: [:get, :post]
  match "demo/chips/remove_callback", to: "pages#chip_remove_callback", via: [:get, :post]
  get "demo/alerts", to: "pages#alerts"
  get "demo/cards", to: "pages#cards"
  get "demo/breadcrumbs", to: "pages#breadcrumbs"
  get "demo/navbar", to: "pages#navbar"
  get "demo/search", to: "pages#search"
  get "demo/search_results", to: "pages#search_results"
  get "demo/picker", to: "pages#picker"
  get "demo/picker_results", to: "pages#picker_results"
  post "demo/picker_submissions", to: "pages#picker_submissions", as: :demo_picker_submissions
  get "demo/sidebar_layout", to: "pages#sidebar_layout"
  get "demo/sidebar/basic", to: "pages#sidebar_basic"
  get "demo/sidebar/header", to: "pages#sidebar_header"
  get "demo/sidebar/footer", to: "pages#sidebar_footer"
  get "demo/sidebar/badges", to: "pages#sidebar_badges"
  get "demo/sidebar/grouped", to: "pages#sidebar_grouped"
  get "demo/sidebar/collapsible", to: "pages#sidebar_collapsible"
  get "demo/sidebar/collapsed", to: "pages#sidebar_collapsed"
  get "demo/sidebar/complete", to: "pages#sidebar_complete"
  get "demo/sidebar/section_title", to: "pages#sidebar_section_title"

  # New component demos
  get "demo/modals", to: "pages#modals"
  get "demo/popovers", to: "pages#popovers"
  get "demo/tooltips", to: "pages#tooltips"
  get "demo/tabs", to: "pages#tabs"
  get "demo/tabs/pills", to: "pages#tabs_pills"
  get "demo/tabs/stacked_pills", to: "pages#tabs_stacked_pills"
  get "demo/toasts", to: "pages#toasts"
  get "demo/page_header", to: "pages#page_header"
  get "demo/text/quote", to: "pages#text_quote"
  get "demo/empty_state", to: "pages#empty_state"
  get "demo/grid", to: "pages#grid"
  get "demo/grid/two_columns", to: "pages#grid_two_columns"
  get "demo/grid/movable_cards", to: "pages#grid_movable_cards"
  get "demo/pagination", to: "pages#pagination"
  get "demo/charts", to: "pages#charts"
  get "demo/code_blocks", to: "pages#code_blocks"
  get "demo/avatars", to: "pages#avatars"
  get "demo/comments", to: "pages#comments"

  get "demo/chat/demo", to: "pages#chat_demo"
  get "demo/chat/layout", to: "pages#chat_layout"
  get "demo/chat/panel", to: "pages#chat_panel"
  get "demo/chat/message_list", to: "pages#chat_message_list"
  get "demo/chat/message_group", to: "pages#chat_message_group"
  get "demo/chat/sent_message", to: "pages#chat_sent_message"
  get "demo/chat/received_message", to: "pages#chat_received_message"
  get "demo/chat/file_message", to: "pages#chat_file_message"
  get "demo/chat/files/:slug", to: "pages#chat_file_download", as: :demo_chat_file_download,
    constraints: {slug: /[a-z0-9-]+/}
  get "demo/chat/images", to: "pages#chat_images"
  get "demo/chat/image_message", to: redirect("/demo/chat/images")
  get "demo/chat/image_deck", to: redirect("/demo/chat/images")
  get "demo/chat/system_message", to: "pages#chat_system_message"
  get "demo/chat/inbox_row", to: "pages#chat_inbox_row"
  get "demo/chat/attachment", to: "pages#chat_attachment"
  get "demo/chat/date_divider", to: "pages#chat_date_divider"
  get "demo/chat/typing_indicator", to: "pages#chat_typing_indicator"
  get "demo/chat/composer", to: "pages#chat_composer"

  get "demo/carousel", to: "pages#carousel"

  namespace :demo do
    resources :comments, only: [:create] do
      post :replies, on: :member
    end

    resources :chat_groups, only: [] do
      resources :messages, only: [:index, :create], controller: "chat_messages" do
        collection do
          post :preview
        end
      end
    end
  end

  get "demo/admin", to: "pages#admin"

  # New components
  get "demo/progress", to: "pages#progress"
  get "demo/collapse", to: "pages#collapse"
  get "demo/pagination_infinite", to: "pages#pagination_infinite"
  get "demo/range_input", to: "pages#range_input"
  get "demo/skeletons", to: "pages#skeletons"
  get "demo/list", to: "pages#list"
  get "demo/timeline", to: "pages#timeline"

  # Form submission endpoints for demonstration
  post "demo/forms/create", to: "pages#forms_create"
  patch "demo/forms/update", to: "pages#forms_update"
  put "demo/forms/update", to: "pages#forms_update"
  delete "demo/forms/destroy", to: "pages#forms_destroy"

  # Mobile demos
  get "mobile", to: "mobile#index"
  get "mobile/bottom_nav", to: "mobile#bottom_nav"

  resources :articles, path: "demo/articles", except: [:destroy]
  post "demo/articles/upload_image", to: "article_images#create", as: :article_upload_image

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "pages#demo"
end
