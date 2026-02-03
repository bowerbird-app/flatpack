# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Pin FlatPack controllers from the engine
pin_all_from File.expand_path("../../../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers"
