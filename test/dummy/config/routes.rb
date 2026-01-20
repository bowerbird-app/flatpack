# frozen_string_literal: true

Rails.application.routes.draw do
  # Mount the FlatPack engine
  mount FlatPack::Engine => "/flat_pack"

  # Demo pages
  get "demo", to: "pages#demo"
  get "demo/buttons", to: "pages#buttons"
  get "demo/tables", to: "pages#tables"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "pages#demo"
end
