# frozen_string_literal: true

# Configure importmap for FlatPack components
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers"
