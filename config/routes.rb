# frozen_string_literal: true

FlatPack::Engine.routes.draw do
  get "ckeditor/*path", to: "ckeditor_assets#show", as: :ckeditor_asset
end
