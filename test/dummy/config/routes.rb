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
  get "demo/sidebar_layout", to: "pages#sidebar_layout"

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
