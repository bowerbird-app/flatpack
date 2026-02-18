# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount the FlatPack engine
  mount FlatPack::Engine => "/flat_pack"

  # Demo pages
  get "demo", to: "pages#demo"
  get "demo/buttons", to: "pages#buttons"
  get "demo/forms", to: "pages#forms"
  get "demo/tables", to: "pages#tables"
  get "demo/inputs", to: "pages#inputs"
  get "demo/badges", to: "pages#badges"
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

  # Form submission endpoints for demonstration
  post "demo/forms/create", to: "pages#forms_create"
  patch "demo/forms/update", to: "pages#forms_update"
  put "demo/forms/update", to: "pages#forms_update"
  delete "demo/forms/destroy", to: "pages#forms_destroy"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Defines the root path route ("/")
  root "pages#demo"
end
