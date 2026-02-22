# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount the FlatPack engine
  mount FlatPack::Engine => "/flat_pack"

  # Demo pages
  get "demo", to: "pages#demo"
  get "themes", to: "themes#index"
  get "demo/buttons", to: "pages#buttons"
  get "demo/forms", to: "pages#forms"
  get "demo/tables", to: "pages#tables"
  patch "demo/tables/reorder", to: "pages#tables_reorder"
  get "demo/inputs", to: "pages#inputs"
  get "demo/badges", to: "pages#badges"
  get "demo/chips", to: "pages#chips"
  get "demo/alerts", to: "pages#alerts"
  get "demo/cards", to: "pages#cards"
  get "demo/breadcrumbs", to: "pages#breadcrumbs"
  get "demo/navbar", to: "pages#navbar"
  get "demo/search", to: "pages#search"
  get "demo/search_results", to: "pages#search_results"
  get "demo/sidebar_layout", to: "pages#sidebar_layout"

  # New component demos
  get "demo/modals", to: "pages#modals"
  get "demo/popovers", to: "pages#popovers"
  get "demo/tooltips", to: "pages#tooltips"
  get "demo/tabs", to: "pages#tabs"
  get "demo/toasts", to: "pages#toasts"
  get "demo/page_header", to: "pages#page_header"
  get "demo/empty_state", to: "pages#empty_state"
  get "demo/grid", to: "pages#grid"
  get "demo/pagination", to: "pages#pagination"
  get "demo/charts", to: "pages#charts"
  get "demo/code_blocks", to: "pages#code_blocks"
  get "demo/avatars", to: "pages#avatars"
  get "demo/comments", to: "pages#comments"
  get "demo/chat", to: "pages#chat"
  get "demo/chat/basic", to: "pages#chat_basic"
  get "demo/chat/states", to: "pages#chat_states"

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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "pages#demo"
end
