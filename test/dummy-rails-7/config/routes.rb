# frozen_string_literal: true

Rails.application.routes.draw do
  mount FlatPack::Engine => "/flat_pack"

  root to: proc { [200, {}, ["OK"]] }
end
