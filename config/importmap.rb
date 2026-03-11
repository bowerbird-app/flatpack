# frozen_string_literal: true

# Configure importmap for FlatPack components
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers", preload: false
pin_all_from File.expand_path("../app/javascript/flat_pack/tiptap", __dir__), under: "flat_pack/tiptap", to: "flat_pack/tiptap", preload: false

# Third-party dependencies
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"
pin "@tiptap/core", to: "https://esm.sh/@tiptap/core?bundle"
pin "@tiptap/starter-kit", to: "https://esm.sh/@tiptap/starter-kit?bundle"
pin "@tiptap/extensions", to: "https://esm.sh/@tiptap/extensions?bundle"
pin "lowlight", to: "https://esm.sh/lowlight?bundle"
pin "yjs", to: "https://esm.sh/yjs?bundle"
