# frozen_string_literal: true

# Configure importmap for FlatPack components
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers"

# Third-party dependencies
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"
