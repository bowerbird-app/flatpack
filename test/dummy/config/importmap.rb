# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "tiptap_demo_addons", to: "tiptap_demo_addons.js"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Third-party dependencies
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"

# Pin FlatPack controllers from the engine
pin_all_from File.expand_path("../../../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers", preload: false
pin_all_from File.expand_path("../../../app/javascript/flat_pack/tiptap", __dir__), under: "flat_pack/tiptap", to: "flat_pack/tiptap", preload: false
pin "flat_pack/heroicons", to: "flat_pack/heroicons.js", preload: false

# TipTap rich text editor dependencies.
TIPTAP_VERSION = "2.27.2" unless defined?(TIPTAP_VERSION)

pin "@tiptap/core", to: "https://esm.sh/@tiptap/core@#{TIPTAP_VERSION}"
pin "@tiptap/starter-kit", to: "https://esm.sh/@tiptap/starter-kit@#{TIPTAP_VERSION}"
pin "@tiptap/extension-bubble-menu", to: "https://esm.sh/@tiptap/extension-bubble-menu@#{TIPTAP_VERSION}"
pin "@tiptap/extension-floating-menu", to: "https://esm.sh/@tiptap/extension-floating-menu@#{TIPTAP_VERSION}"
pin "@tiptap/extension-placeholder", to: "https://esm.sh/@tiptap/extension-placeholder@#{TIPTAP_VERSION}"
pin "@tiptap/extension-character-count", to: "https://esm.sh/@tiptap/extension-character-count@#{TIPTAP_VERSION}"
pin "@tiptap/extension-link", to: "https://esm.sh/@tiptap/extension-link@#{TIPTAP_VERSION}"
pin "@tiptap/extension-underline", to: "https://esm.sh/@tiptap/extension-underline@#{TIPTAP_VERSION}"
pin "@tiptap/extension-text-align", to: "https://esm.sh/@tiptap/extension-text-align@#{TIPTAP_VERSION}"
pin "lowlight", to: "https://esm.sh/lowlight@3"
pin "@tiptap/extension-highlight", to: "https://esm.sh/@tiptap/extension-highlight@#{TIPTAP_VERSION}"
pin "@tiptap/extension-text-style", to: "https://esm.sh/@tiptap/extension-text-style@#{TIPTAP_VERSION}"
pin "@tiptap/extension-color", to: "https://esm.sh/@tiptap/extension-color@#{TIPTAP_VERSION}"
pin "@tiptap/extension-typography", to: "https://esm.sh/@tiptap/extension-typography@#{TIPTAP_VERSION}"
pin "@tiptap/extension-image", to: "https://esm.sh/@tiptap/extension-image@#{TIPTAP_VERSION}"
pin "@tiptap/extension-code-block-lowlight", to: "https://esm.sh/@tiptap/extension-code-block-lowlight@#{TIPTAP_VERSION}"
pin "@tiptap/extension-task-list", to: "https://esm.sh/@tiptap/extension-task-list@#{TIPTAP_VERSION}"
pin "@tiptap/extension-task-item", to: "https://esm.sh/@tiptap/extension-task-item@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table", to: "https://esm.sh/@tiptap/extension-table@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-row", to: "https://esm.sh/@tiptap/extension-table-row@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-cell", to: "https://esm.sh/@tiptap/extension-table-cell@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-header", to: "https://esm.sh/@tiptap/extension-table-header@#{TIPTAP_VERSION}"
pin "@tiptap/extension-subscript", to: "https://esm.sh/@tiptap/extension-subscript@#{TIPTAP_VERSION}"
pin "@tiptap/extension-superscript", to: "https://esm.sh/@tiptap/extension-superscript@#{TIPTAP_VERSION}"
pin "@tiptap/extension-font-family", to: "https://esm.sh/@tiptap/extension-font-family@#{TIPTAP_VERSION}"
pin "@tiptap/extension-mention", to: "https://esm.sh/@tiptap/extension-mention@#{TIPTAP_VERSION}"
pin "@tiptap/extension-youtube", to: "https://esm.sh/@tiptap/extension-youtube@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details", to: "https://esm.sh/@tiptap/extension-details@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details-content", to: "https://esm.sh/@tiptap/extension-details-content@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details-summary", to: "https://esm.sh/@tiptap/extension-details-summary@#{TIPTAP_VERSION}"
pin "@tiptap/extension-unique-id", to: "https://esm.sh/@tiptap/extension-unique-id@#{TIPTAP_VERSION}"
pin "@tiptap/extension-focus", to: "https://esm.sh/@tiptap/extension-focus@#{TIPTAP_VERSION}"
pin "@tiptap/extension-list-keymap", to: "https://esm.sh/@tiptap/extension-list-keymap@#{TIPTAP_VERSION}"
pin "@tiptap/extension-collaboration", to: "https://esm.sh/@tiptap/extension-collaboration@#{TIPTAP_VERSION}"
pin "@tiptap/extension-collaboration-cursor", to: "https://esm.sh/@tiptap/extension-collaboration-cursor@#{TIPTAP_VERSION}"
pin "@tiptap/extension-drag-handle", to: "https://esm.sh/@tiptap/extension-drag-handle@#{TIPTAP_VERSION}"
pin "@tiptap/extension-mathematics", to: "https://esm.sh/@tiptap/extension-mathematics@#{TIPTAP_VERSION}"
pin "@tiptap/extension-emoji", to: "https://esm.sh/@tiptap/extension-emoji@#{TIPTAP_VERSION}"
pin "@tiptap/extension-invisible-characters", to: "https://esm.sh/@tiptap/extension-invisible-characters@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-of-contents", to: "https://esm.sh/@tiptap/extension-table-of-contents@#{TIPTAP_VERSION}"
